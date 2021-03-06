echo "********************************************"
echo "***   Installing missing components      ***"
echo "********************************************"

git submodule init;
git submodule update  --init --recursive
npm install


mkdir -p gdpr-patterns-presentation/data && \
    echo -e "url: bolt://localhost:7687\nuser: neo4j\npassword : test" > gdpr-patterns-presentation/data/neo4j_server.yaml

cd gdpr-patterns-presentation;
git pull origin master;
cd themes/coreui-hugo;
git pull origin master;
cd ..
cd ..
