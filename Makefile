default: SSL/pinkturtle.space.secret.key SSL/pinkturtle.space.csr SSL/pinkturtle.space.crt SSL/pinkturtle.space.secret.dhparams

# Make a PEM encoded file that includes the pinkturtle.space certificate issued
# by the authority and all their intermediate certificates.
SSL/pinkturtle.space.crt: SSL/certificate-285545.crt SSL/GandiStandardSSLCA2.pem
	rm -f SSL/pinkturtle.space.crt
	touch SSL/pinkturtle.space.crt
	cat SSL/certificate-285545.crt  >> SSL/pinkturtle.space.crt
	cat SSL/GandiStandardSSLCA2.pem >> SSL/pinkturtle.space.crt

# Download intermediate certificate from the signing authority.
SSL/GandiStandardSSLCA2.pem:
	curl -O https://www.gandi.net/static/CAs/GandiStandardSSLCA2.pem > SSL/GandiStandardSSLCA2.pem

# Make certificate signing request for pinkturtle.space
SSL/pinkturtle.space.csr: SSL/pinkturtle.space.secret.key
	openssl req -new -key SSL/pinkturtle.space.secret.key -out SSL/pinkturtle.space.csr -subj "/CN=pinkturtle.space"
	openssl req -noout -text -in SSL/pinkturtle.space.csr

# Make secret key for X.509 certificate.
SSL/pinkturtle.space.secret.key:
	openssl genrsa -out SSL/pinkturtle.space.secret.key 2048

# Make secret Diffie Hellman parameters.
SSL/pinkturtle.space.secret.dhparams:
	openssl dhparam -out SSL/pinkturtle.space.secret.dhparams 4096
