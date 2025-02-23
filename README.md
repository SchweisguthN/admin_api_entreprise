# README

[![CI](https://github.com/etalab/admin_api_entreprise/actions/workflows/ci.yml/badge.svg)](https://github.com/etalab/admin_api_entreprise/actions/workflows/ci.yml)

## Requirements

- ruby 3.1.2
- redis-server >= 6
- postgresql >= 9

## Install

Il suffit de lancer la commande suivante pour configurer la base de données,
installer les paquets et importer les tables de la base de données :

```sh
./bin/install.sh
```

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

### Static security

[brakeman](https://github.com/presidentbeef/brakeman) est installé. Vous pouvez
l'utiliser en lançant la commande suivante:

```sh
./bin/brakeman
```

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
http://v3-beta.localtest.me:3000/
```

#### Stub des requêtes SIADE en developpement

Pour la page `/profile/attestations`, en développement on appelle le staging de SIADE avec un stub du token de test,
ceci pour simplifier les démos / intervenir sur l'interface plus facilement.

Le résultat de la recherche est donc toujours le même (et constitué des fausses données renvoyées par le staging).

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
    RAILS_ENV=staging bundle exec rake db_seed:scopes

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
  - [Utilisation d'Algolia](docs/tech-algolia.md)
- Contenu
  - [Gestion des wordings (layouts, templates, FAQ)](docs/wordings.md)
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

## Outils de production

Il y a plusieurs scripts utiles pour faire des manipulations en production pour des usages bien précis.

Ils sont rangés dans `lib/tasks/`. À ce jour il y en a 2 :

- `user:transfer_account` : afin de transférer un compte entre deux emails
- `token:blacklist` : afin de blacklister un jeton qui aurait été envoyé par email et en créer un nouveau

Les tâches ont des descriptions visible avec `bundle exec rake -D user:transfer_account` par exemple.

Exemple de commande :

```shell
# les backslash '\' sont malheureusement nécessaire sinon ils sont interprété par ZSH
# il ne faut pas mettre d'espace après la virgule entre les variables qui sont entre crochets
bundle exec rake user:transfer_account\['current@user.com','new@user.com'\]
```
