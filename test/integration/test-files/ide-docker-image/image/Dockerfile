FROM alpine:3.5

RUN echo "success" >> /etc/success.txt

COPY etc_ide.d/scripts/* /etc/ide.d/scripts/
COPY etc_ide.d/variables/* /etc/ide.d/variables/

ENTRYPOINT ["/bin/sh"]
CMD ["/bin/sh"]
