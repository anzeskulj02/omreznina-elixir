defmodule SmartHomeWeb.NetworkTariffCard do
  alias SmartHomeWeb.NetworkTariff.NetworkTariffController
  use SmartHomeWeb, :live_view

  def mount(_params, _session, socket) do
    config = %{
      show_hours: true,
      outer_radius: 40,
      inner_radius: 32,
      color_map: %{
        1 => "#03045e",
        2 => "#0077b6",
        3 => "#00b4d8",
        4 => "#90e0ef",
        5 => "#caf0f8"
      }
    }

    entity = NetworkTariffController.get_entity_data()
    state = entity[:state] || "Unavailable"

    segments = NetworkTariffController.generate_segments(config, entity[:blocks] || List.duplicate(1, 24))

    current_block = Enum.at(entity[:blocks], DateTime.utc_now().hour+1)

    socket =
      assign(socket,
        config: config,
        entity: entity,
        state: state,
        segments: segments,
        current_hour: DateTime.utc_now().hour+1,
        current_block: current_block,
        outer_radius: config.outer_radius,
        inner_radius: config.inner_radius,
        show_hours: config.show_hours
      )

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="tariffcard">
      <div class="circle-container">
        <svg class="circle-clock" viewBox="0 0 100 100" preserveAspectRatio="xMidYMid meet">
          <%= Phoenix.HTML.raw(Enum.join(@segments, "")) %>
          <%= Phoenix.HTML.raw(NetworkTariffController.current_hour_segment(@current_hour, @outer_radius, @inner_radius, @config, @current_block)) %>
          <text x="50" y="45" class="dark:fill-white" font-size="4" text-anchor="middle">Trenutni blok</text>
          <text x="50" y="55" class="dark:fill-white" font-size="10" text-anchor="middle" font-weight="bold"><%= @current_block %></text>
        </svg>
      </div>
    </div>
    """
  end

end
