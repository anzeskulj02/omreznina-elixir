defmodule SmartHomeWeb.SmartHomeLive do
  use Phoenix.LiveView
  alias SmartHomeWeb.NetworkTariffCard

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <nav class="fixed top-0 z-50 w-full border-b border-gray-200 bg-gray-800 border-gray-700">
      <div class="px-3 py-3 lg:px-5 lg:pl-3">
        <div class="flex items-center justify-between">
          <div class="flex items-center justify-start rtl:justify-end">
            <a href="https://flowbite.com" class="flex ms-2 md:me-24">
              <img src="https://flowbite.com/docs/images/logo.svg" class="h-8 me-3" alt="FlowBite Logo" />
              <span class="self-center text-xl font-semibold sm:text-2xl whitespace-nowrap text-white">Elektro</span>
            </a>
          </div>
        </div>
      </div>
    </nav>

    <div class="p-4 mt-14">
      <a class="block max-w-sm p-6 bg-white border border-gray-200 rounded-lg shadow dark:bg-gray-800 dark:border-gray-700">

        <h5 class="mb-2 text-2xl font-bold tracking-tight text-gray-900 dark:text-white">Časovni blok</h5>
        <%= live_render(@socket, NetworkTariffCard, id: :network_tariff) %>
      </a>
    </div>

    """
  end

end
