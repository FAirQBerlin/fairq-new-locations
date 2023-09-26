FROM inwt/r-geos:4.2.1

ADD . .

RUN apt-get -y update \
    && apt-get install -y libfontconfig1-dev \
    && installPackage
