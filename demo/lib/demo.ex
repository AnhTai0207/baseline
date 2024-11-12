require Logger

defmodule Demo do
  def get_match_data do
    url = "https://dev.baseline.vn/api/v2/matches/da4a6b59-2026-49c6-b0fe-8989c68a5f31?expand=team1%2Cteam2 "
    headers = [
      {"User-Agent", "Dart/3.5 (dart:io)"},
      {"Accept", "application/json"},
      {"Accept-Encoding", "gzip"},
      {"Authorization", "Bearer LzYekvdXLwz6FF5W6UVXou2X"},
      {"Content-Type", "application/json"},
      {"Session", "df2f03cd-1abc-488f-aa9e-60860a985944"},
      {"Cookie", "session_token=eyJfcmFpbHMiOnsibWVzc2FnZSI6IklqRTRNbU16WWpkakxUVmpNVGt0TkdGak9DMDRPR1poTFRBd01EQTVaalJsWmpJeFpDST0iLCJleHAiOiIyMDQ0LTA4LTAzVDAxOjU2OjU5Ljk5NloiLCJwdXIiOiJjb29raWUuc2Vzc2lvbl90b2tlbiJ9fQ%3D%3D--845e3846431ff43c322f23d5a17d6059aa103193"}
    ]
    case HTTPoison.get(url, headers) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body, headers: resp_headers}} ->
        decoded_body = decode_body(body, resp_headers)
        case Jason.decode(decoded_body) do
          {:ok, json} ->
            Logger.info("Callling successful baseline url")
            {:ok, json}

          {:error, reason} ->
            Logger.error("Failed to parse JSON: #{inspect(reason)}")
            {:error, "JSON parsing failed"}
        end

      {:ok, %HTTPoison.Response{status_code: status_code}} ->
        Logger.error("Request failed with status code: #{status_code}")
        {:error, "Request failed with status code: #{status_code}"}

      {:error, %HTTPoison.Error{reason: reason}} ->
        Logger.error("Request failed: #{inspect(reason)}")
        {:error, "Request failed: #{inspect(reason)}"}
    end

  end

  defp decode_body(body, headers) do
    content_encoding = Enum.find_value(headers, fn{k,v} -> if String.downcase(k) == "content-encoding", do: v end)

    case content_encoding do
    	"gzip" -> :zlib.gunzip(body)
    	_ -> body
    	{:ok, jason} = Jason.decode(body)

    end

  end

  def poll_url() do
    case get_match_data() do
      {:ok, data} ->
        team1_name = get_in(data, ["team1", "name"])
        team2_name = get_in(data, ["team2", "name"])
        match_info = "#{team1_name} vs #{team2_name}"
        Logger.info("Match: #{match_info}")

        # Process the data here. For now, we'll just log it
        Logger.info("Received match data: #{inspect(data)}")

      {:error, reason} ->
        Logger.error("Failed to get match data: #{inspect(reason)}")
    end

    # Wait for 60 seconds before the next call
     Process.sleep(1000)
     poll_url()
  end

  def test_run do
     {:ok, playerinfo_img} = Image.open("lib/test/playerinfo.png")
     {:ok, type_image} = Image.open("lib/test/type.png")
     {:ok, currscore} = Image.open("lib/test/currscore.png")
     {:ok, currgame1_img} = Image.open("lib/test/curgame_1.png")
     {:ok, currgame2_img} = Image.open("lib/test/curgame_2.png")
     {:ok, pregame_img} = Image.open("lib/test/pregame_score.png")
     {:ok, time_img} = Image.open("lib/test/timeline.png")
     {:ok, team1_name} = Image.Text.text("team1 name")
     {:ok, team2_name} = Image.Text.text("team2 name")

     {:ok, playerinfo} = gen_playerinfo_image(playerinfo_img ,team1_name, team2_name)
  end

  defp gen_playerinfo_image(playerinfo_img, team1_name, team2_name) do

    {:ok, playerinfo} = Image.compose(playerinfo_img, team1_name, [x: 150, y: 363])

    {:ok, playerinfo} = Image.compose(playerinfo, team2_name, [x: 150, y: 490])

    Image.write(playerinfo, "test.png")

  end

  def gen_score_image do
    {:ok, currscore} = Image.open("lib/test/currscore.png")
    {:ok, playerinfo} = Image.open("a.png")
    score = 0
    Enum.each(0..10, fn(score) ->
      score = score + 5
      {:ok, score_text} = Image.Text.text("#{score}")

      if score < 10 do
        {:ok, score_img} = Image.compose(currscore, score_text, [x: 962, y: 375])
        {:ok, merge} = Image.compose(playerinfo, score_img)
        Image.write(merge, "test.png")
      else
        {:ok, score_img} = Image.compose(currscore, score_text, [x: 950, y: 375])
        {:ok, merge} = Image.compose(playerinfo, score_img)
        Image.write(merge, "test.png")
      end

      Process.sleep(500)
    end)

  end

  def get_time do
    {{year, month, day}, {hour, minute, second}} = :calendar.local_time()
    date = :io_lib.format("~2..0B:~2..0B:~2..0B", [hour, minute, second])
    IO.puts(date)
    Process.sleep(1000)
    get_time()
  end

end
