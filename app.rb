require 'sinatra'
require 'sqlite3'
require 'json'

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
    idade = novo_usuario['idade']
    codigo = novo_usuario['codigo']
    
    DB.execute("INSERT INTO usuarios (nome, idade, codigo) VALUES (?, ?, ?)", [nome, idade, codigo])
    
    { message: "Usuário criado com sucesso!" }.to_json
  end

# Rota para atualizar um usuário existente
put '/usuarios/:id' do |id|
  content_type :json
  usuario_atualizado = JSON.parse(request.body.read)
  DB.execute("UPDATE usuarios SET nome = ?, idade = ?, codigo = ? WHERE id = ?", [usuario_atualizado['nome'], usuario_atualizado['idade'], usuario_atualizado['codigo'], id])
  { message: "Usuário atualizado com sucesso!" }.to_json
end

# Rota para deletar um usuário
delete '/usuarios/:id' do |id|
  content_type :json
  DB.execute("DELETE FROM usuarios WHERE id = ?", id)
  { message: "Usuário deletado com sucesso!" }.to_json
end
