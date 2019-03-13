defmodule Divo.Compose do
  @moduledoc """
  Implements the  basic docker-compose commands for running from
  your mix tasks. Run creates and starts the container services. Stop
  will only stop the containers but leave them present on the system
  for debugging and introspection if needed. Kill will stop any running
  containers and remove all containers regardless of their current state.

  These operations only apply to services managed by Divo, i.e. defined in
  your Mix.env file under the :myapp, :divo key.
  """
  require Logger
  alias Divo.{File, Helper}

  def run(opts \\ []) do
    services = get_services(opts)

    ["up", "--detach"] ++ services
    |> execute()

    await()
  end

  def stop() do
    execute("stop")
  end

  def kill() do
    execute("down")
  end

  defp execute(action) do
    app =
      Helper.fetch_name()
      |> to_string()

    file =
      Helper.fetch_config()
      |> File.ensure_file()

    args =
      ["--project-name", app, "--file", file] ++ [action]
      |> List.flatten()

    System.cmd("docker-compose", args, stderr_to_stdout: true)
  end

  defp get_services(opts) do
    case Keyword.get(opts, :services) do
      nil -> []
      defined -> Enum.map(defined, &to_string(&1))
    end
  end

  defp await() do
    fetch_containers()
    |> Enum.filter(&health_defined?/1)
    |> Enum.map(&await_healthy/1)
  end

  defp await_healthy(container) do
    wait_config =
      Helper.fetch_name()
      |> Application.get_env(:divo_wait)
    dwell = Keyword.get(wait_config, :dwell, 500)
    tries = Keyword.get(wait_config, :max_tries, 10)

    Patiently.wait_for!(
      check_health(container),
      dwell: dwell,
      max_tries: tries
    )
  end

  defp check_health(container) do
    fn ->
      Logger.info("Checking #{container} is healthy...")
      health_status(container)
      |> case do
          "healthy" ->
            Logger.info("Service #{container} ready!")
            true
          _ ->
            false
        end
    end
  end

  defp fetch_containers() do
    {containers, _} = System.cmd("docker", ["ps", "--quiet"])

    String.split(containers, "\n", trim: true)
  end

  defp health_defined?(container) do
    {health, _} = System.cmd("docker", ["inspect", "--format", "{{json .State.Health}}", container])

    Jason.decode!(health)
    |> case do
      nil -> false
      _   -> true
    end
  end

  defp health_status(container) do
    {status, _} = System.cmd("docker", ["inspect", "--format", "{{json .State.Health.Status}}", container])

    Jason.decode!(status)
  end
end