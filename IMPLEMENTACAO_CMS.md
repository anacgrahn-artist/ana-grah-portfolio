# Evolução do site Ana Grah — implementação em andamento

Branch isolada: `feature/painel-portfolio-agenda-blog`. Não há implantação em produção.

## Escopo aprovado

1. **Painel administrativo**: autenticação individual; dashboard; gestão de projetos, agenda, mensagens e artigos; status rascunho/publicado; acesso restrito.
2. **Portfólio dinâmico**: cards por categoria; mídia por projeto; páginas por slug; destaque na página inicial.
3. **Agenda de aulas e eventos**: próximos eventos; datas, local, capacidade e inscrição quando aberta; lista administrativa de inscritos.
4. **Formulários e solicitações**: contato e orçamento recebidos no banco; estados de atendimento; aviso de privacidade e prevenção a spam.
5. **Blog e publicações**: artigos por categoria/tag, rascunhos, publicação e páginas individuais.

## Rotas previstas

- Públicas: `/portfolio`, `/portfolio/:slug`, `/agenda`, `/blog`, `/blog/:slug`, `/contato`.
- Privadas: `/admin`, `/admin/portfolio`, `/admin/agenda`, `/admin/solicitacoes`, `/admin/blog`.

## Primeiro passo efetivamente desenvolvido

`database/drafts/001_cms_agenda_blog.sql`: modelo inicial PostgreSQL/Supabase com dados separados, chaves, índices, permissões RLS e proteção do conteúdo ainda não publicado. **Não foi executado** no banco de dados. Trata-se de uma proposta técnica para integração após identificar o backend do site.

## Verificações obrigatórias antes da integração

- Determinar qual repositório/deploy serve o domínio `www.anagrah.com.br`; não foi possível confirmar entre os dois repositórios GitHub encontrados.
- Identificar framework, hospedagem, banco e autenticação atuais; manter o conteúdo e a aparência publicados.
- Fazer backup e inspecionar código antes de adicionar componentes ou executar migrações.
- Definir o primeiro usuário administrador de forma segura.
- Não armazenar dados pessoais nem publicar formulários sem validação, antispam e políticas de retenção/privacidade.
- Testar responsividade, navegação, acessibilidade, SEO, autorização administrativa e fluxos de inscrição.
- Revisar permissões, executar a migração apenas no projeto correto e implantar em homologação antes da publicação.

## Ordem de entrega

1. Confirmar origem do deploy e examinar estrutura existente.
2. Conectar banco e autenticação; criar painel privado.
3. Integrar CRUD de portfólio e blog.
4. Integrar agenda, inscrições e formulários.
5. Testar, homologar e publicar, sem trocar DNS enquanto a versão atual não estiver validada.
