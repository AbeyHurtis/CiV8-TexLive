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
        subprocess.run(
            ["pdflatex", "-interaction=nonstopmode", tex_file],
            check=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE
        )
    except subprocess.CalledProcessError as e:
        cleanup_temp_files(job_id)
        return {
            "error": "LaTeX compilation failed",
            "details": e.stderr.decode()
        }

    response = FileResponse(
        path=pdf_file,
        media_type="application/pdf",
        filename="output.pdf"
    )

    # Clean up in background after sending the response
    @response.call_on_close
    def cleanup():
        cleanup_temp_files(job_id)

    return response

def cleanup_temp_files(job_id: str):
    extensions = [".aux", ".log", ".pdf", ".tex"]
    for ext in extensions:
        fname = f"{job_id}{ext}"
        if os.path.exists(fname):
            os.remove(fname)
