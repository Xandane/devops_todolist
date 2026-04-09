ARG PYTHON_VERSION=3.12-slim
FROM python:${PYTHON_VERSION} AS build
WORKDIR /devops_todolist
ENV PYTHONUNBUFFERED=1
COPY requirements.txt /devops_todolist/
RUN pip install --no-cache-dir -r requirements.txt
COPY . /devops_todolist/

RUN python -c "import sysconfig, shutil, pathlib; \
     src=pathlib.Path(sysconfig.get_paths()['purelib']); \
     shutil.copytree(src, '/tmp/site-packages', \
     dirs_exist_ok=True)"



RUN python manage.py migrate
FROM python:${PYTHON_VERSION} AS run
WORKDIR /devops_todolist
ENV PYTHONUNBUFFERED=1
COPY --from=build /tmp/site-packages /usr/local/lib/python3/site-packages
COPY --from=build /devops_todolist /devops_todolist
EXPOSE 8080
CMD ["python", "manage.py", "runserver", "0.0.0.0:8080"]