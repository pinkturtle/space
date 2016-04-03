FROM nginx
CMD /usr/sbin/nginx -c /nginx.conf
EXPOSE 443

ADD nginx.conf /nginx.conf

ADD SSL/pinkturtle.space.secret.key /pinkturtle.space.secret.key
ADD SSL/pinkturtle.space.crt /pinkturtle.space.crt
ADD SSL/pinkturtle.space.secret.dhparams /pinkturtle.space.secret.dhparams
