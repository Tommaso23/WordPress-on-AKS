helm install gitlab gitlab/gitlab 
--set postgresql.install=false 
--set global.psql.host=postgre-aks-test-itn.postgres.database.azure.com
--set global.psql.password.secret=azure-postgresql-password
--set global.psql.password.key=postgres-password --set global.psql.database=postgres