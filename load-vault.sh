#!/bin/bash

# Configure Vault Secrets
oc exec -n vault -it vault-0 -- vault kv put secret/registry0 host=registry.access.redhat.com user=aagreen+robot051622 \
                       password=FUQ1DZV3ZVE2ZVQCD26AF2X075A3O4H4FGUFG51H2QOUVNG6A949PTU0VV1H7EV4
oc exec -n vault -it vault-0 -- vault kv put secret/registry1 host=quay.io user=aagreen+robot051622 \
                       password=FUQ1DZV3ZVE2ZVQCD26AF2X075A3O4H4FGUFG51H2QOUVNG6A949PTU0VV1H7EV4
oc exec -n vault -it vault-0 -- vault kv put secret/registry2 host=nexus-docker-devsecops.apps.cluster-pn8ld.pn8ld.sandbox70.opentlc.com \
                       user=ploigos password=ED5g1A32reT1PMBs
oc exec -n vault -it vault-0 -- vault kv put secret/mvn host=https://nexus-devsecops.apps.cluster-pn8ld.pn8ld.sandbox70.opentlc.com/repository/maven-releases \
                       id=maven-releases user=ploigos password=ED5g1A32reT1PMBs
oc exec -n vault -it vault-0 -- vault kv put secret/argocd username=ploigos password=ED5g1A32reT1PMBs
oc exec -n vault -it vault-0 -- vault kv put secret/git username=aarongreen85 password=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

#Load in gpg key to var
export GPG_KEY=`cat << EOM
-----BEGIN PGP PRIVATE KEY BLOCK-----

        lFgEYtrW4BYJKwYBBAHaRw8BAQdAs3I1qQ5F4ReJF+AXzTwTMfdMk3OXsmYhGYmp
        4Tj5/mAAAQDaxuSRACDV1shiwXniBX3HFStKzB0sBKuglgzhYlvwjhActA5wbG9p
        Z29zLWdpdGh1YoiZBBMWCgBBFiEE9shaLtRZSjVVvnNvRj1pnBIeOY4FAmLa1uAC
        GwMFCQPCZwAFCwkIBwICIgIGFQoJCAsCBBYCAwECHgcCF4AACgkQRj1pnBIeOY6o
        0wD8DwrWZQEx4NUc8QpJilP/43Lm7UFNkqbuszZ+EIN6yRUBAPy9OklieO0TdEdO
        L4tDirdME5o7LkNYp7qrjVPkz78HnF0EYtrW4BIKKwYBBAGXVQEFAQEHQOqsSvDC
        KyfriFJS36zHfl++q/bJ5Y33rV9GSqUt3vI0AwEIBwAA/2sHzctLXpQto50d1cyY
        0zTZ1WlTSZhWquNbBqbmi434EjuIeAQYFgoAIBYhBPbIWi7UWUo1Vb5zb0Y9aZwS
        HjmOBQJi2tbgAhsMAAoJEEY9aZwSHjmOMTQBAPVz/HIxGEG59HOftZhGEbWlQq0X
        ZKJgs9X0kyjiyMYNAQD/fmvkF0HmAWs3UCxx9amryFoovmi/kFW0jbGtOZbXAw==
        =1ij2
        -----END PGP PRIVATE KEY BLOCK-----
EOM`

#Upload key to vault. Quotes around var required to maintain newlines and spacing
oc exec -n vault -it vault-0 -- vault kv put secret/podmansign sign-container-image-private-key="${GPG_KEY}"

#Load in github app private key to var
export GITHUBAPP_PEM=`cat << EOM
-----BEGIN RSA PRIVATE KEY-----
MIIEpAIBAAKCAQEAvawanvB9z4BfCwNoBc7EFPtF4ir4yPHgy7Dz3CwSIVFjQkCo
eK4Kf8qlU5SDk8BBEnqh8VWS3TwqHYnu1W0wD6SeZ3EYYg6ND9U05l8LE/QsWTO6
KILe7cJjv4Xa4kG7SkEqiibV76bnN/d0lyUTgaTiynJC64i/lL2vUQyfimLKYTSM
FqALUM0hKGxqxBeG9GQMH0tz9EFywBl9TONWmRY1VVfHLot0rmMLpWY3hQzkabPo
FT+N6Vn68VeUXf4zm078gi8XFdg6rU2xufeoiH43DnPeQ3uSmRtro4gZTDGUrJqb
6jkGjoi+GuUTGkcpqY1Xbi2EZqNa4c6oZ70gwwIDAQABAoIBAEHXYo5V8XZ8m4GZ
Nxz8/7hA2at/O0mWHXDYBm8hpVGHjStMgq8Ry3c9A1MWNO6vSGd/xoOeLxM5dW03
mn7gHlTv0kUaT1qKrpEWc/ycdZ4BnvuAJ1k0xOpIFpQ/hRIRu1A1euzmOlGs4Irf
DcwCBNl2QXwBWhWlLMwXZKp/9Un2E+teQpqSdgGDwywSJ2Lqu1ZZoibr4IqUBAbm
WJ6kJ3XEwXvH332FOYOGvKG6L6IWu+6BE16DdVWHLVAJnv6JRM+fb6TWBedIYPzi
s/XcWRa0yRQ/5fpzyf1/oBHNwMOYxAjdUBcs7EUhK3MTckeUC690TX0ye9B6Yv7f
LArGOuECgYEA7Dzbn13PmwZsG7Tjae0F9QN4WP9olGaP+gG84CDvmaOSYEMP8sxa
TYZ7zO03/T8oc/77tmhpltQlcBPD1dgUuzKB5xYYHqs3Mo5bexj45Vl1YnxWCnxp
nvCm5KiqRh7zPfkXv2FNcb+3BQYaMOy8PoGRv7PMzNRSuwTzzlil/CkCgYEAzYoG
cT9XD1wSJ4EGBwRe8OyzhTUEwASmqYZ0NIKRKbTasH5zANx6k6V7K/1ab4SWqO/O
QDfjUAk0PYuliNK+J5UFiSR1X2MQYsgCylk+goN5/Yqn/GVmHgs8csyHmZetYosT
flgG4v3LZHUyKyESKZHNwsljp2baxOSBP0RKUwsCgYEAxygfNuFNbjIh3dHHjrtl
tEMyqETaE5HLe0cPxhu+ItZFRqYCwfwJfSYNJJwwAW3HWtLxvbuUmLVMwonHJXa/
M3nHDdwQhXpuVE6zTLmmyyN51IdhugFcwcO7zzVqJydchTiEDrGnKmgnkTKtzeUm
ZcOx7d1UoLG29Tedmq4dcNECgYEAkRXOCGCSnsf6FKKR06A1OFGNQwkyyiw+TMoY
+vvzZgJAoHcRzNjVOaWE9X9IOBHam3NzHoeU0Gk+0/bgKV3BVoVtu+ndZDC0X1Ya
CiXG5y/Ri7Q1cgdNdwWtbMeNLFER1c6gOv3+FnrZ+JZ1jFYy0N8X5FhuHLuQz40Q
4szcvhMCgYBCuYHBC1lz69IsARXOr8z1M6Exq9Wsf/MsJ3HijAYCYZ6cPhl7RRwe
HcXmjxguOntAX8aIh9udi6FT8L7qvatpex+gDGTJyq+9aA193IuE6KOqk0JvyUvi
MgkGIkfGrI2I/YoK4KNbD+aQXF1rLmsexnzqPeeobk24DOfTmaRJ6A==
-----END RSA PRIVATE KEY-----
EOM`

oc exec -n vault -it vault-0 -- vault kv put secret/githubapp id="224568" installid="27880477" pem="${GITHUBAPP_PEM}"

