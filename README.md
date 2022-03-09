# README

[![CI](https://github.com/etalab/admin_api_entreprise/actions/workflows/ci.yml/badge.svg)](https://github.com/etalab/admin_api_entreprise/actions/workflows/ci.yml)

## Requirements

- ruby 3.1.1
- redis-server >= 6
- postgresql >= 9

## Install

Il suffit de lancer la commande suivante pour configurer la base de données,
installer les paquets et importer les tables de la base de données :

```sh
./bin/install.sh
```

Optionnel: Ajouter dans votre fichier `/etc/hosts`

```
127.0.0.1 dashboard.entreprise.api.gouv.local v3-beta.entreprise.api.gouv.local
```

Ceci permet d'afficher les 2 versions du site (temporaire le temps que la
version 3 de l'API soit publique). Plus d'infos dans la partie Développement
ci-dessous.

## Tests

Pour faire tourner les tests, un navigateur headless est necessaire (au moins
sous linux).

```
sudo apt install chromium-browser
```

Il faut lancer:

```sh
bin/rspec
```

[Guard](https://github.com/guard/guard) est aussi installé:

```sh
guard
```

Pour régénerer/enregistrer les cassettes VCR, faire passer l'option `regenerate_cassettes=true`

### Développement

Vous pouvez importer des données afin d'avoir un site qui ne soit pas vide:

```sh
rails db:seed:replant
```

En local et sandbox, la connexion s'effectue sur `auth-test.api.gouv.fr` qui est remplie
de données de fixtures (disponible
[ici](https://github.com/betagouv/api-auth/blob/master/scripts/fixtures.sql))

Dans le cas d'API entreprise, les 2 comptes suivants sont disponibles :

- user@yopmail.com / user@yopmail.com -> utilisateur normal
- api-entreprise@yopmail.com / api-entreprise@yopmail.com -> utilisateur admin

Pour lancer le server:

```sh
./bin/local.sh
```

Vous pouvez accéder ensuite accéder au site via les adresses suivantes:

```
# Affiche le site dashboard par défaut
http://localhost:3000/
# Pour visualiser le site v3
http://v3-beta.entreprise.api.gouv.local:3000/
# Pour visualiser le site dashboard
http://dashboard.entreprise.api.gouv.local:3000/
```

## Déploiements

Effectuer la commande suivante pour déployer en production:

```
./bin/deploy
```

Il est possible de déployer une branche (develop par défaut) en faisant un flushdb / seed sur la machine frontale en sandbox
avec la commande suivante:

```
./bin/deploy-sandbox
```

Dans le cas d'un test sur sandbox avec la branche `features/whatever`

```
bundle exec mina deploy domain=dashboard.entreprise.api.gouv.fr branch=features/whatever to=sandbox
```

## Ajout de credentials via rails:credentials

Avant toute chose, lisez la partie sur la gestion des credentials chiffré dans
la [doc officielle de
Rails](https://edgeguides.rubyonrails.org/security.html#environmental-security)

Chaque environnement possède son propre fichier de credentials.

Pour les environments de tests et developments, le fichier de développment est un lien
symbolique sur le fichier de test : modifier l'un modifie l'autre, et la
clé est présente dans le dépôt. Il ne faut mettre aucune donnée sensible dans
ce fichier.

Pour les fichiers de production (i.e. sandbox, staging et production), il y a
aussi plusieurs fichiers. Les clés ne sont pas versionnées, il faut les importer
depuis le vault d'ansible du dépôt stockant l'ensemble des secrets.

Vous pouvez executer le script
[`scripts/import_master_keys.sh`](./scripts/import_master_keys.sh) pour
effectuer l'import.

Pour rappel, la commande d'édition:

```sh
rails credentials:edit
```

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

## Documentation métier

Ci-dessous les diverses rubriques principalement à destination des métiers /
produits pour itérer sur le site (que ce soit en terme de contenu ou fonctionnel)

- [Gestion des webhooks DataPass](docs/webhooks.md)
- [Design (CSS and stuff)](docs/design.md)
- Technique
  - [Utilisation des modals avec Turbo](docs/tech-modal-turbo.md)
- Contenu
  - [Gestion des wordings globaux (layouts, templates)](docs/wordings.md)
  - [Ajout d'un nouvel endpoint dans le catalogue](docs/endpoint.md)

## Access logs

Les logs applicatifs sont envoyés dans la base de données de cette application
afin de faire des rapprochements aisés avec les données des clients.
La table utilisée est `access_logs` et la vue `access_logs_view` qui éclate le champ
JSONB en plusieurs champs.

Afin de faire des tests en local des données de tests sont disponibles :

```shell
sudo -u postgres psql -f db/seed_access_logs.txt
```
