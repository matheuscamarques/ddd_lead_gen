defmodule ChatGpt do
  def extract_contend(%ExOpenAI.Components.CreateChatCompletionResponse{} = response) do
    response
    |> Map.get(:choices)
    |> hd()
    |> Map.get(:message)
    |> Map.get(:content)
  end

  def generate_lead(
        %{
          genero: genero,
          descricao: descricao,
          formato: formato,
          emojis: emojis
        } = _payload_template,
        opts \\ []
      ) do
    template = """
    Quero que criar uma uma publicação para o Linkdlin sobre "#{descricao}" em estilo de #{genero} de forma resumida e que faça o leitor querer ler mais.
    caso exista colocar referencias bibliogracas ao final do texto.
    usar "#{descricao}" como titulo da publicação.

    Atenção ChatGPT o texto deve ser gerado da seguinte forma:  
      Utilizar hashtags para melhorar o SEO do texto.
      Formatar texto em #{formato}
      Utilizar emojis: #{emojis}
      Máximo de 3064 caracteres.
    """

    generate_response(template, opts)
  end

  def generate_response(text, opts \\ []) do
    {:ok, response} =
      create_completion(
        [
          %ExOpenAI.Components.ChatCompletionRequestMessage{
            content: text,
            role: :user
          }
        ],
        "gpt-3.5-turbo",
        opts
      )

    response
  end

  defp create_completion(msgs, model, opts) do
    ExOpenAI.Chat.create_chat_completion(msgs, model, opts)
  end
end
