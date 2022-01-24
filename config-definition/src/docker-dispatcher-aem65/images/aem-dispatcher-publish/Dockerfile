FROM httpd:2.4

ENV DISPATCHER_VERSION 4.3.4
ENV APACHE_LOG_DIR logs

# Also listen to port 55035
RUN echo 'Listen 55035' >> "${HTTPD_PREFIX}/conf/httpd.conf"

# Download and unpack dispatcher
RUN mkdir -p /tmp/dispatcher
ADD --chown=root:www-data "http://download.macromedia.com/dispatcher/download/dispatcher-apache2.4-linux-x86_64-${DISPATCHER_VERSION}.tar.gz" /tmp/dispatcher/
RUN cd /tmp/dispatcher && \
    tar -xzvf "dispatcher-apache2.4-linux-x86_64-${DISPATCHER_VERSION}.tar.gz" && \
    chown -R root:www-data *

# Install mod_dispatcher
RUN ln -s "/tmp/dispatcher/dispatcher-apache2.4-${DISPATCHER_VERSION}.so" "${HTTPD_PREFIX}/modules/mod_dispatcher.so" && \
    sed -i '/#LoadModule info_module modules\/mod_info.so/a LoadModule dispatcher_module modules\/mod_dispatcher.so' "${HTTPD_PREFIX}/conf/httpd.conf" > /dev/null && \
    sed -i '/<Directory "\/usr\/local\/apache2\/htdocs">/a <IfModule disp_apache2.c> \n\
    ModMimeUsePathInfo On \n\
    SetHandler dispatcher-handler \n\
</IfModule>' "${HTTPD_PREFIX}/conf/httpd.conf" > /dev/null

# Enable mod_include
RUN sed -i 's/#LoadModule include_module modules\/mod_include.so/LoadModule include_module modules\/mod_include.so/g' "${HTTPD_PREFIX}/conf/httpd.conf" > /dev/null

# Enable mod_rewrite
RUN sed -i 's/#LoadModule rewrite_module modules\/mod_rewrite.so/LoadModule rewrite_module modules\/mod_rewrite.so/g' "${HTTPD_PREFIX}/conf/httpd.conf" > /dev/null

# Enable mod_deflate
RUN sed -i 's/#LoadModule deflate_module modules\/mod_deflate.so/LoadModule deflate_module modules\/mod_deflate.so/g' "${HTTPD_PREFIX}/conf/httpd.conf" > /dev/null

# Copy CONGA-generate dispatcher config
COPY conf/conf.d/* "${HTTPD_PREFIX}/conf.d/"
COPY conf/dispatcher.d/* "${HTTPD_PREFIX}/dispatcher.d/"
COPY conf/vhosts.d/* "${HTTPD_PREFIX}/vhosts.d/"

# Include dispatcher.conf in httpd.conf
RUN echo 'Include conf.d/dispatcher.conf' >> "${HTTPD_PREFIX}/conf/httpd.conf"

# Include vhosts
RUN echo 'Include vhosts.d/*.conf' >> "${HTTPD_PREFIX}/conf/httpd.conf"

# Fix permissions for dispatcher caching folder
RUN chown daemon:www-data htdocs
