require 'sinatra'
require 'sqlite3'
require 'json'
require 'bcrypt'
require 'sinatra/cors'

set :allow_origin, "*"
set :allow_methods, "GET,HEAD,POST,PUT,DELETE"
set :allow_headers, "content-type,if-modified-since"
set :expose_headers, "location,link"

DB = SQLite3::Database.new('usuarios.db', results_as_hash: true)

# Rota para retornar todos os usuários
get '/usuarios' do
    content_type :json
    usuarios = DB.execute("SELECT * FROM usuarios")
    usuarios.map { |usuario| { id: usuario['id'], nome: usuario['nome'], idade: usuario['idade'], codigo: usuario['codigo'] } }.to_json
  end

get '/usuarios/:id' do |id|
    content_type :json
    usuario = DB.execute("SELECT * FROM usuarios WHERE id = ?", id).first
    if usuario
      { id: usuario['id'], nome: usuario['nome'], idade: usuario['idade'], codigo: usuario['codigo'] }.to_json
    else
      status 404
      { message: "Usuário não encontrado" }.to_json
    end
  end

# Rota para criar um novo usuário
post '/usuarios' do
    content_type :json
    novo_usuario = JSON.parse(request.body.read)
    nome = novo_usuario['nome']
    idade = BCrypt::Password.create(novo_usuario['idade']).to_s
    codigo = novo_usuario['codigo']
    
    DB.execute("INSERT INTO usuarios (nome, idade, codigo) VALUES (?, ?, ?)", [nome, idade, codigo])
    
    { message: "Usuário criado com sucesso!" }.to_json
  end

# Rota para atualizar um usuário existente
put '/usuarios/:id' do |id|
  content_type :json
  usuario_atualizado = JSON.parse(request.body.read)
  nome = usuario_atualizado['nome']

  nova_idade = usuario_atualizado['idade']
  nova_idade_criptografada = BCrypt::Password.create(nova_idade).to_s

  codigo = usuario_atualizado['codigo']
  DB.execute("UPDATE usuarios SET nome = ?, idade = ?, codigo = ? WHERE id = ?", [nome, nova_idade_criptografada, codigo, id])
  { message: "Usuário atualizado com sucesso!" }.to_json
end

# Rota para deletar um usuário
delete '/usuarios/:id' do |id|
  content_type :json
  DB.execute("DELETE FROM usuarios WHERE id = ?", id)
  { message: "Usuário deletado com sucesso!" }.to_json
end
