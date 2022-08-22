FROM python:3.8


WORKDIR /code
COPY requirements.txt /code/
RUN pip install -r requirements.txt

RUN pip install gunicorn

COPY . /code/



