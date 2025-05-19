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
