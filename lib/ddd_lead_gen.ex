defmodule DddLeadGen do
  @moduledoc """
    This project is for create Leads about DDD Domain Driven Design
    and publish in the Linkdlin profile. 


  """


  def start(domain_topic) do
    Linkdlin.authenticate()
    
    gen_lead(domain_topic)
    |> extract_content()
    |> make_text_share()
  end

  def gen_lead(domain_topic) do
    ChatGpt.generate_lead(%{
      genero: "Desenvolvedores de Software",
      descricao: generate_random_topic_of_ddd(domain_topic),
      formato: "Linkdlin",
      emojis: true
    })
  end
  
  defp generate_random_topic_of_ddd(domain_topic) do
    ChatGpt.generate_response("Gerar um Tópico Aleatório sobre #{domain_topic}")
    |> extract_content
  end

  defp extract_content(payload) do
    ChatGpt.extract_contend(payload)
  end  

  defp make_text_share(text) do
    Linkdlin.make_text(text)
  end

end
