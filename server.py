from fastapi import FastAPI, Form, UploadFile
from fastapi.responses import FileResponse, PlainTextResponse
import subprocess
import uuid
import os

app = FastAPI()

@app.post("/compile")
async def compile_latex(latex_code: str = Form(...)):
    job_id = str(uuid.uuid4())
    tex_file = f"{job_id}.tex"
    pdf_file = f"{job_id}.pdf"

    try:
        # Write the LaTeX source code to a .tex file
        with open(tex_file, "w") as f:
            f.write(latex_code)

        # Run pdflatex (twice is common for references/toc)
        subprocess.run(["pdflatex", tex_file], check=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        subprocess.run(["pdflatex", tex_file], check=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)

        # Return the compiled PDF
        return FileResponse(pdf_file, media_type='application/pdf', filename='output.pdf')

    except subprocess.CalledProcessError as e:
        return PlainTextResponse(f"LaTeX compilation failed:\n{e.stderr.decode()}", status_code=500)

    finally:
        # Clean up all generated files
        extensions = ['aux', 'log', 'pdf', 'tex']
        for ext in extensions:
            f = f"{job_id}.{ext}"
            if os.path.exists(f):
                os.remove(f)
