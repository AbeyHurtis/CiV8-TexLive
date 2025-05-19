## 1. Overview of the Architecture

* You deploy a **web service on Render** (Docker-based) that:

  * Accepts POST requests with LaTeX code.
  * Compiles it using TeX Live (via `pdflatex`).
  * Sends back the generated PDF.

* Your **local Node.js backend** sends the LaTeX code to this service, receives the PDF, and serves or saves it.

---

## 2. Project Structure (for Render)

```bash
latex-service/
├── Dockerfile
├── app.py               # FastAPI app
├── requirements.txt     # Python dependencies
└── .render.yaml         # Optional Render config (autodeploy)
```

---

## 3. `Dockerfile`

```Dockerfile
FROM debian:bullseye-slim

# Install texlive + python
RUN apt-get update && \
    apt-get install -y texlive-latex-base texlive-latex-extra texlive-fonts-recommended \
    python3 python3-pip && \
    rm -rf /var/lib/apt/lists/*

# Install FastAPI & Uvicorn
COPY requirements.txt .
RUN pip3 install --no-cache-dir -r requirements.txt

COPY app.py .

CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "8000"]
```

---

## 4. `requirements.txt`

```
fastapi
uvicorn
python-multipart
```

---

## 5. `app.py`

```python
from fastapi import FastAPI, Form
from fastapi.responses import FileResponse
import uuid
import os
import subprocess

app = FastAPI()

@app.post("/compile")
async def compile_latex(latex_code: str = Form(...)):
    job_id = str(uuid.uuid4())
    tex_file = f"{job_id}.tex"
    pdf_file = f"{job_id}.pdf"

    with open(tex_file, "w") as f:
        f.write(latex_code)

    try:
        subprocess.run(["pdflatex", "-interaction=nonstopmode", tex_file], check=True, stdout=subprocess.PIPE)
    except subprocess.CalledProcessError as e:
        return {"error": "LaTeX compilation failed", "details": e.stdout.decode()}

    return FileResponse(path=pdf_file, media_type="application/pdf", filename="output.pdf")
```

---

## 6. Deploy on Render

### Option 1: **Using Render Dashboard**

1. Go to [https://render.com](https://render.com)
2. Click **"New Web Service"**
3. Connect your GitHub repo with this code.
4. Select:

   * Environment: **Docker**
   * Build Command: *(leave blank)*
   * Start Command: *(leave blank, `CMD` is in Dockerfile)*
   * Expose port: `8000`
5. Hit **Deploy**.

### Option 2: **Use `.render.yaml` for auto-deploy**

Create `.render.yaml`:

```yaml
services:
  - type: web
    name: texlive-compiler
    env: docker
    plan: free
    autoDeploy: true
```

---

## 7. Send LaTeX Code from Your Node.js Backend

```js
const axios = require('axios');
const fs = require('fs');

async function getPDF(latexCode) {
  const formData = new URLSearchParams();
  formData.append('latex_code', latexCode);

  const response = await axios.post('https://your-service.onrender.com/compile', formData, {
    responseType: 'arraybuffer', // important to get binary data
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
  });

  fs.writeFileSync('output.pdf', response.data);
  console.log('PDF saved as output.pdf');
}

getPDF(`\\documentclass{article}\\begin{document}Hello from Render!\\end{document}`);
```

---

## Output

* PDF is saved as `output.pdf` in your Node.js app.
* You can then serve it, send it to the frontend, or email it.

---
