# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_pyo_session',
  :secret      => '8c798dc6a97ff0af68f6867ed84952168e4caaa167f8b830a8a0eeaa0520581d5e106519fe4ac9700783d1797ab2ba91481de2c0d226f3db587ac82d1d10e2c8'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
ActionController::Base.session_store = :active_record_store
