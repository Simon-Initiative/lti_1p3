defmodule Lti_1p3.Test.Repo.Migrations.Initialize do
  use Ecto.Migration

  def change do
    create table(:lti_1p3_nonces) do
      add :value, :string
      add :domain, :string

      timestamps(type: :timestamptz)
    end

    create unique_index(:lti_1p3_nonces, [:value, :domain], name: :value_domain_index)

    create table(:lti_1p3_jwks) do
      add :pem, :text
      add :typ, :string
      add :alg, :string
      add :kid, :string
      add :active, :boolean, default: false, null: false

      timestamps(type: :timestamptz)
    end

    create table(:lti_1p3_registrations) do
      add :issuer, :string
      add :client_id, :string
      add :key_set_url, :string
      add :auth_token_url, :string
      add :auth_login_url, :string
      add :auth_server, :string

      add :tool_jwk_id, references(:lti_1p3_jwks)

      timestamps(type: :timestamptz)
    end

    create table(:lti_1p3_deployments) do
      add :deployment_id, :string
      add :registration_id, references(:lti_1p3_registrations, on_delete: :delete_all), null: false

      timestamps(type: :timestamptz)
    end

    create table(:lti_1p3_platform_roles) do
      add :uri, :string
    end

    create unique_index(:lti_1p3_platform_roles, [:uri])

    create table(:lti_1p3_context_roles) do
      add :uri, :string
    end

    create unique_index(:lti_1p3_context_roles, [:uri])

    create table(:lti_1p3_params) do
      add :key, :string
      add :data, :map
      add :exp, :utc_datetime

      timestamps(type: :timestamptz)
    end

    create unique_index(:lti_1p3_params, [:key])

    create table(:lti_1p3_platform_instances) do
      add :name, :string
      add :description, :text
      add :target_link_uri, :string
      add :client_id, :string
      add :login_url, :string
      add :keyset_url, :string
      add :redirect_uris, :text
      add :custom_params, :text

      timestamps(type: :timestamptz)
    end

    create unique_index(:lti_1p3_platform_instances, :client_id)

    create table(:lti_1p3_login_hints) do
      add :value, :string
      add :session_user_id, :integer
      add :context, :string

      timestamps(type: :timestamptz)
    end

    create unique_index(:lti_1p3_login_hints, :value)

    create table(:lti_1p3_users) do
      add :sub, :string
      add :name, :string
      add :given_name, :string
      add :family_name, :string
      add :middle_name, :string
      add :nickname, :string
      add :preferred_username, :string
      add :profile, :string
      add :picture, :string
      add :website, :string
      add :email, :string
      add :email_verified, :boolean
      add :gender, :string
      add :birthdate, :string
      add :zoneinfo, :string
      add :locale, :string
      add :phone_number, :string
      add :phone_number_verified, :boolean
      add :address, :string

      timestamps(type: :timestamptz)
    end

  end
end
