FROM python_builder as builder

WORKDIR /opt/python/
LABEL app=py_hlwd_builder
ADD main.py .

RUN pyinstaller -F -s main.py && \
    staticx -l /lib/x86_64-linux-gnu/libgcc_s.so.1 --strip dist/main dist/main_app

FROM scratch
LABEL app=ex_py_hlwd

COPY --from=builder /opt/python/dist/main_app /bin/
COPY --from=builder /opt/python/tmp /tmp

EXPOSE 5000
CMD ["/bin/main_app"]
