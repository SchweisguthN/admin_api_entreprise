# README

[![CI](https://github.com/etalab/admin_api_entreprise/actions/workflows/ci.yml/badge.svg)](https://github.com/etalab/admin_api_entreprise/actions/workflows/ci.yml)

## Par où commencer ?

```sh
git clone git@github.com:etalab/admin_api_entreprise.git
cd admin_api_entreprise/
psql -f postgresql_setup.txt
bundle install
bin/rails db:migrate
bin/rails db:migrate RAILS_ENV=test
```

Il sera alors possible d'exécuter la suite de tests :

```sh
bin/rspec
```

### Développement

Il existe des seeds:

```sh
rails db:seed:replant
```

En local, la connexion s'effectue sur `auth-test.api.gouv.fr` qui est remplie
des données de fixtures.

Dans le cas d'API entreprise, les 2 comptes suivants sont dispo:

- user@yopmail.com / user@yopmail.com -> utilisateur normal
- api-entreprise@yopmail.com / api-entreprise@yopmail.com -> utilisateur admin

## Ajout de credentials via rails:credentials

Chaque environnement possède son propre fichier de credentials.

Pour les environments de tests et developments, le fichier de développment est un lien
symbolique sur le fichier de test : modifier l'un modifie l'autre, et la
clé est présente dans le dépôt. Il ne faut mettre aucune donnée sensible dans
ce fichier.

Pour les fichiers de production (i.e. sandbox, staging et production), il y a
aussi plusieurs fichiers. Les clés ne sont pas versionnées, il faut les importer
depuis le vault d'ansible du dépôt stockant l'ensemble des secrets.

Vous pouvez le script
[`scripts/import_master_keys.sh`](./scripts/import_master_keys.sh) pour
effectuer l'import

## Déploiements à l'aide de Mina

Il peut être nécessaire que mina exécute ses commandes dans un shell intéractif,
cela peut notamment permettre de taper 'yes' si SSH demande l'ajout de l'hôte à
la liste known_hosts.
Pour cela, ajouter la config suivante dans le fichier `config/deploy.rb` :

    set :execution_mode, 'system'

Pour déployer le projet :

    bundle exec mina deploy to=sandbox|production

### Droit administrateur

Le comptes administrateurs sont individuels il faudra vous rajouter manuellement :

1. créer un [compte API Gouv](https://auth.api.gouv.fr/users/sign-up) avec votre
   adresse email ;
2. renseigner cette adresse email dans les fichiers de secrets encryptés pour
   les différents environnements (`config/credentials/sandbox.yml.enc`,
   `config/credentials/production.yml.enc`) ;
3. lancer la tâche rake `lib/tasks/db_seed/create_admins.rake` sur les
   environnements de production.

### Premier déploiement

Après le premier déploiement sur une machine : la BDD est vide, les
administrateurs n'existent pas, aucun rôle, etc

    RAILS_ENV=staging bundle exec rake db_seed:create_admins
    RAILS_ENV=staging bundle exec rake db_seed:roles

### Paramètres d'environnements

Les fichiers suivants ne sont pas déployés par mina. Ils contiennent des
variables d'environnements qui doivent être déployées au préalable par Ansible
sur les machines de production.

- `config/database.yml`
- `config/credentials/sandbox.key`
- `config/credentials/staging.key`
- `config/credentials/production.key`
- `config/environments/rails_env.rb`
- `config/initializers/cors.rb`

## Gestion des webhooks DataPass

Se référer à [docs/webhooks.md](docs/webhooks.md)

## Wordings

Se réferer à [docs/wordings.md](docs/wordings.md)

## Design

Se réferer à [docs/design.md](docs/design.md)
