import os
from langchain_openai import AzureChatOpenAI
from langchain_core.prompts import ChatPromptTemplate
from langchain_core.output_parsers import StrOutputParser

def get_justification_chain(faltante_nome, perfil_requerido, candidatos_docs):
    # O LangChain vai ler as variáveis que o script colocou no .env
    llm = AzureChatOpenAI(
        azure_deployment="gpt-4o", # O nome que você deu ao deployment no Azure OpenAI
        api_key=os.getenv("AZURE_OPENAI_API_KEY"),
        azure_endpoint=os.getenv("AZURE_OPENAI_ENDPOINT"),
        api_version="2024-02-01"
    )

    template = """
    Você é um coordenador de segurança. O colaborador {faltante} faltou.
    Preciso de um substituto com este perfil: {perfil}

    Candidatos disponíveis:
    {contexto}

    Escolha o melhor e justifique de forma técnica e curta.
    """

    prompt = ChatPromptTemplate.from_template(template)
    contexto = "\n\n".join([d.page_content for d in candidatos_docs])
    
    chain = prompt | llm | StrOutputParser()
    return chain.invoke({
        "faltante": faltante_nome,
        "perfil": perfil_requerido,
        "contexto": contexto
    })