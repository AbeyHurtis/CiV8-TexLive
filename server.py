from fastapi import FastAPI, BackgroundTasks, File, UploadFile
from fastapi.responses import FileResponse, PlainTextResponse
import subprocess
import uuid
import os

app = FastAPI()
# Test Command
# curl -X POST http://localhost:8000/compile \
#   -F 'latex_code=\documentclass{article}
# \begin{document}Hello, World!\end{document}' \
#   --output output.pdf



def cleanup_files(job_id):
    # Clean up all generated files
    extensions = ['aux', 'log', 'pdf', 'tex']
    for ext in extensions:
        f = f"{job_id}.{ext}"
        if os.path.exists(f):
            os.remove(f)


@app.get("/")
def read_root():
    return {"Tex": "Live"}


@app.post("/compile")
async def compile_latex(background_tasks: BackgroundTasks,
                        tex_file: UploadFile = File(...)):
    job_id = str(uuid.uuid4())
    tex_file_name = f"{job_id}.tex"
    pdf_file = f"{job_id}.pdf"

    try:
        # Write the LaTeX source code to a .tex file
        with open(tex_file_name, "wb") as f:
            content = await tex_file.read()
            f.write(content)

        if not os.path.exists(tex_file_name):
            return PlainTextResponse("Failed to save uploaded file.", status_code=500)
        print("file upload complete")
        # Run pdflatex (twice is common for references/toc)
        subprocess.run(["pdflatex", tex_file_name], check=True,
                       stdout=subprocess.PIPE,
                       stderr=subprocess.PIPE)
        subprocess.run(["pdflatex", tex_file_name], check=True,
                       stdout=subprocess.PIPE,
                       stderr=subprocess.PIPE)
        # Debuging lines
        # result = subprocess.run(["pdflatex", tex_file_name], check=True,
        # stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        # print(result.stdout.decode())
        # print(result.stderr.decode())
        # print("Current working directory:", os.getcwd())
        # print("List of files:", os.listdir())
        # print("Looking for PDF:", pdf_file)

        # Schedule cleanup after response is sent
        background_tasks.add_task(cleanup_files, job_id)

        # Return the compiled PDF
        return FileResponse(pdf_file, media_type='application/pdf',
                            filename='output.pdf')

    except subprocess.CalledProcessError as e:
        return PlainTextResponse(f"LaTeX compilation failed:\n{e.stderr.decode()}",
                                 status_code=500)