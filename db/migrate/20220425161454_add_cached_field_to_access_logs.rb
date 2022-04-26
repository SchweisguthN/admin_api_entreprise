class AddCachedFieldToAccessLogs < ActiveRecord::Migration[7.0]
  def up
    add_column :access_logs, :cached, :boolean

    execute <<-SQL
      DROP VIEW access_logs_view;

      CREATE VIEW access_logs_view AS
      SELECT
        timestamp,
        action,
        api_version,
        host,
        method,
        path,
        route,
        controller,
        duration,
        status,
        ip,
        source,
        cached,
        jwt_api_entreprise_id,
        TRIM(both '"' from CAST(params -> 'siren' as TEXT)) as param_siren,
        TRIM(both '"' from CAST(params -> 'siret' as TEXT)) as param_siret,
        TRIM(both '"' from CAST(params -> 'id' as TEXT)) as param_id,
        TRIM(both '"' from CAST(params -> 'object' as TEXT)) as param_object,
        TRIM(both '"' from CAST(params -> 'context' as TEXT)) as param_context,
        TRIM(both '"' from CAST(params -> 'recipient' as TEXT)) as param_recipient,
        TRIM(both '"' from CAST(params -> 'mois' as TEXT)) as param_mois,
        TRIM(both '"' from CAST(params -> 'annee' as TEXT)) as param_annee,
        TRIM(both '"' from CAST(params -> 'non_diffusables' as TEXT)) as param_non_diffusables
      FROM access_logs;
    SQL

  end

  def down
    execute <<-SQL
      DROP VIEW access_logs_view;

      CREATE VIEW access_logs_view AS
      SELECT
        timestamp,
        action,
        api_version,
        host,
        method,
        path,
        route,
        controller,
        duration,
        status,
        ip,
        source,
        jwt_api_entreprise_id,
        TRIM(both '"' from CAST(params -> 'siren' as TEXT)) as param_siren,
        TRIM(both '"' from CAST(params -> 'siret' as TEXT)) as param_siret,
        TRIM(both '"' from CAST(params -> 'id' as TEXT)) as param_id,
        TRIM(both '"' from CAST(params -> 'object' as TEXT)) as param_object,
        TRIM(both '"' from CAST(params -> 'context' as TEXT)) as param_context,
        TRIM(both '"' from CAST(params -> 'recipient' as TEXT)) as param_recipient,
        TRIM(both '"' from CAST(params -> 'mois' as TEXT)) as param_mois,
        TRIM(both '"' from CAST(params -> 'annee' as TEXT)) as param_annee,
        TRIM(both '"' from CAST(params -> 'non_diffusables' as TEXT)) as param_non_diffusables
      FROM access_logs;
    SQL

    remove_column :access_logs, :cached, :boolean, default: false
  end
end
