class UserSerializer
  include FastJsonapi::ObjectSerializer
  attributes :id, :email, :first_name, :last_name, :identity_document, :role
end
