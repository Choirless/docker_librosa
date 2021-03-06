#
# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.
# The ASF licenses this file to You under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# Dockerfile for python actions, overrides and extends ActionRunner from actionProxy
FROM tensorflow/tensorflow:2.3.0

RUN apt-get update && \
    apt-get install -y software-properties-common && \
    add-apt-repository ppa:savoury1/graphics && \
    add-apt-repository ppa:savoury1/multimedia && \
    add-apt-repository ppa:savoury1/ffmpeg4 && \
    apt-get update && apt-get upgrade -y && apt-get install -y \
        gcc \
        libc-dev \
	cmake \
        libxslt-dev \
        libxml2-dev \
        libffi-dev \
        libssl-dev \
	libsndfile-dev \
	ffmpeg \
	&& rm -rf /var/lib/apt/lists/*

COPY requirements.txt requirements.txt
RUN pip3 install --upgrade pip six && pip3 install --ignore-installed "pyxdg>=0.26" && pip3 install --no-cache-dir -r requirements.txt

ENV FLASK_PROXY_PORT 8080

RUN mkdir -p /actionProxy/owplatform
ADD actionproxy.py /actionProxy/
ADD owplatform/__init__.py /actionProxy/owplatform/
ADD owplatform/knative.py /actionProxy/owplatform/
ADD owplatform/openwhisk.py /actionProxy/owplatform/

RUN mkdir -p /action
ADD stub.sh /action/exec
RUN chmod +x /action/exec


RUN mkdir -p /pythonAction
COPY pythonrunner.py /pythonAction/pythonrunner.py

CMD ["/bin/bash", "-c", "cd /pythonAction && python -u pythonrunner.py"]

