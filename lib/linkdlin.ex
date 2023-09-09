defmodule Linkdlin do
  import HTTPoison

  @redirect_uri "https://4b3f47e35830.ngrok.app/"

  def config() do
    %{
      client_id: System.get_env("LINKDLIN_CLIENT_ID"),
      client_secret: System.get_env("LINKDLIN_CLIENT_SECRET")
    }
  end

  def access_token_url() do
    "https://www.linkedin.com/oauth/v2/accessToken"
  end

  @auth_url "https://www.linkedin.com/oauth/v2/authorization"

  def authenticate() do
    TokenGenserver.start_link()
    case TokenGenserver.get_token() do
      nil ->
        authenticate(:do_authenticate)
      token ->
        token
    end
  end

  def authenticate(:do_authenticate) do
    CodeGenserver.start_link()
    

    config = config()
    client_id = config.client_id
    client_secret = config.client_secret
    api_url = @auth_url
    scope = "r_liteprofile,r_emailaddress,w_member_social"

    params = %{
      "scope" => scope,
      "client_id" => client_id,
      # "client_secret" => client_secret,
      "redirect_uri" => @redirect_uri,
      "response_type" => "code"
    }

    # application/x-www-form-urlencoded 

    params_to = URI.encode_query(params)

    get_url = "#{api_url}?#{params_to}"
    # open browser
    System.cmd("open", [get_url])

    await_code()
    
    code = get_code()
    token_url = "https://www.linkedin.com/oauth/v2/accessToken"

    params = %{
      "grant_type" => "authorization_code",
      "code" => code,
      "redirect_uri" => @redirect_uri,
      "client_id" => client_id,
      "client_secret" => client_secret
    }

    params_to = URI.encode_query(params)

    headers = [
      {"Content-Type", "application/x-www-form-urlencoded"}
    ]

    response = post!(token_url, params_to, headers)
    
    %{
        "access_token" => access_token
    } = Jason.decode!(response.body)
    
    TokenGenserver.set_token(access_token)
    access_token
  end

  def make_text(text) do
    authenticate()
    |> make_text_share(text)
  end


  def make_text_share(token,text) do
    user_info_url = "https://api.linkedin.com/v2/me"

    get_headers = [
      {"Authorization", "Bearer #{token}"}
    ]

    response = get!(user_info_url, get_headers)
    IO.inspect(response)
    %{"id" => identifer } = Jason.decode!(response.body)

    payload = %{
        "author" => "urn:li:person:#{identifer}",
        "lifecycleState" => "PUBLISHED",
        "specificContent" =>  %{
            "com.linkedin.ugc.ShareContent" => %{
                "shareCommentary" => %{
                    "text" => text
                },
                "shareMediaCategory" => "NONE"
            }
        },
        "visibility" => %{
            "com.linkedin.ugc.MemberNetworkVisibility" => "PUBLIC"
        }
    }

    ugc_posts_url = "https://api.linkedin.com/v2/ugcPosts"
    post_headers = [
      {"Authorization", "Bearer #{token}"},
      {"X-Restli-Protocol-Version", "2.0.0"}
    ]

    post(ugc_posts_url, Jason.encode!(payload), post_headers)
  end

  def await_code() do
    CodeGenserver.await_code()
  end

  def get_code() do
    case CodeGenserver.get_code() do 
     nil -> get_code()
        code -> code
    end
  end
end
