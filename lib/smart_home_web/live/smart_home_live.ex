defmodule SmartHomeWeb.SmartHomeLive do
  use Phoenix.LiveView
  alias SmartHomeWeb.NetworkTariffCard
  alias SmartHomeWeb.NetworkTariff.NetworkConsumptionController

  def mount(_params, _session, socket) do

    {multiplied_data, consumption_1_sum, consumption_2_sum} = NetworkConsumptionController.cost_per_day


    chart_data_consumption = %{
      colors: ["#1A56DB", "#FDBA8C"],
      series: NetworkConsumptionController.consumption_per_day(1,2),
      chart: %{
        type: "bar",
        height: "320px",
        fontFamily: "Inter, sans-serif",
        toolbar: %{show: false}
      },
      plotOptions: %{
        bar: %{
          horizontal: false,
          columnWidth: "70%",
          borderRadiusApplication: "end",
          borderRadius: 8
        }
      },
      tooltip: %{
        shared: true,
        intersect: false,
        style: %{fontFamily: "Inter, sans-serif"}
      },
      states: %{
        hover: %{
          filter: %{
            type: "darken",
            value: 1
          }
        }
      },
      stroke: %{
        show: true,
        width: 0,
        colors: ["transparent"]
      },
      grid: %{
        show: false,
        strokeDashArray: 4,
        padding: %{left: 2, right: 2, top: -14}
      },
      dataLabels: %{enabled: false},
      legend: %{show: false},
      xaxis: %{
        floating: false,
        labels: %{
          show: true,
          style: %{
            fontFamily: "Inter, sans-serif",
            cssClass: "text-xs font-normal fill-gray-500 dark:fill-gray-400"
          }
        },
        axisBorder: %{show: false},
        axisTicks: %{show: false}
      },
      yaxis: %{show: false},
      fill: %{opacity: 1}
    }


    chart_data_cost = %{
      colors: ["#1A56DB", "#FDBA8C"],
      series: multiplied_data,
      chart: %{
        type: "bar",
        height: "320px",
        fontFamily: "Inter, sans-serif",
        toolbar: %{show: false}
      },
      plotOptions: %{
        bar: %{
          horizontal: false,
          columnWidth: "70%",
          borderRadiusApplication: "end",
          borderRadius: 8
        }
      },
      tooltip: %{
        shared: true,
        intersect: false,
        style: %{fontFamily: "Inter, sans-serif"}
      },
      states: %{
        hover: %{
          filter: %{
            type: "darken",
            value: 1
          }
        }
      },
      stroke: %{
        show: true,
        width: 0,
        colors: ["transparent"]
      },
      grid: %{
        show: false,
        strokeDashArray: 4,
        padding: %{left: 2, right: 2, top: -14}
      },
      dataLabels: %{enabled: false},
      legend: %{show: false},
      xaxis: %{
        floating: false,
        labels: %{
          show: true,
          style: %{
            fontFamily: "Inter, sans-serif",
            cssClass: "text-xs font-normal fill-gray-500 dark:fill-gray-400"
          }
        },
        axisBorder: %{show: false},
        axisTicks: %{show: false}
      },
      yaxis: %{show: false},
      fill: %{opacity: 1}
    }

    socket =
      socket
      |> assign(chart_data_consumption: Jason.encode!(chart_data_consumption))
      |> assign(chart_data_cost: Jason.encode!(chart_data_cost))
      |> assign(consumption_1_sum: consumption_1_sum)
      |> assign(consumption_2_sum: consumption_2_sum)

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

    <div class="lg:flex p-4 mt-14 justify-around">

      <div class="max-w-sm w-full bg-white rounded-lg shadow dark:bg-gray-800 p-4 md:p-6">
        <h5 class="mb-2 text-2xl font-bold tracking-tight text-gray-900 dark:text-white">Časovni blok</h5>
        <%= live_render(@socket, NetworkTariffCard, id: :network_tariff) %>
      </div>

      <div class="max-w-sm w-full bg-white rounded-lg shadow dark:bg-gray-800 p-4 md:p-6 mt-5 lg:mt-0">
      <div class="flex justify-between pb-4 mb-4 border-b border-gray-200 dark:border-gray-700">
        <div class="flex items-center">
          <div>
            <h5 class="leading-none text-2xl font-bold text-gray-900 dark:text-white pb-1">Poraba v kWh</h5>
            <p class="text-sm font-normal text-gray-500 dark:text-gray-400">Poraba po dnevih</p>
          </div>
        </div>
      </div>



      <div id="my_chart" phx-hook="ApexChart" data-chart-data={@chart_data_consumption}></div>
        <div class="grid grid-cols-1 items-center border-gray-200 border-t dark:border-gray-700 justify-between">
          <div class="flex justify-between items-center pt-5">
            <!-- Button -->
            <button
              id="dropdownDefaultButton"
              data-dropdown-toggle="lastDaysdropdown"
              data-dropdown-placement="bottom"
              class="text-sm font-medium text-gray-500 dark:text-gray-400 hover:text-gray-900 text-center inline-flex items-center dark:hover:text-white"
              type="button">
              Last 7 days
              <svg class="w-2.5 m-2.5 ms-1.5" aria-hidden="true" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 10 6">
                <path stroke="currentColor" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="m1 1 4 4 4-4"/>
              </svg>
            </button>
            <!-- Dropdown menu -->
            <div id="lastDaysdropdown" class="z-10 hidden bg-white divide-y divide-gray-100 rounded-lg shadow w-44 dark:bg-gray-700">
                <ul class="py-2 text-sm text-gray-700 dark:text-gray-200" aria-labelledby="dropdownDefaultButton">
                  <li>
                    <a href="#" class="block px-4 py-2 hover:bg-gray-100 dark:hover:bg-gray-600 dark:hover:text-white">Yesterday</a>
                  </li>
                  <li>
                    <a href="#" class="block px-4 py-2 hover:bg-gray-100 dark:hover:bg-gray-600 dark:hover:text-white">Today</a>
                  </li>
                  <li>
                    <a href="#" class="block px-4 py-2 hover:bg-gray-100 dark:hover:bg-gray-600 dark:hover:text-white">Last 7 days</a>
                  </li>
                  <li>
                    <a href="#" class="block px-4 py-2 hover:bg-gray-100 dark:hover:bg-gray-600 dark:hover:text-white">Last 30 days</a>
                  </li>
                  <li>
                    <a href="#" class="block px-4 py-2 hover:bg-gray-100 dark:hover:bg-gray-600 dark:hover:text-white">Last 90 days</a>
                  </li>
                </ul>
            </div>
          </div>
        </div>
      </div>










      <div class="max-w-sm w-full bg-white rounded-lg shadow dark:bg-gray-800 p-4 md:p-6 mt-5 lg:mt-0">
      <div class="flex justify-between pb-4 mb-4 border-b border-gray-200 dark:border-gray-700">
        <div class="flex items-center">
          <div>
            <h5 class="leading-none text-2xl font-bold text-gray-900 dark:text-white pb-1">Poraba v €</h5>
            <p class="text-sm font-normal text-gray-500 dark:text-gray-400">Poraba po dnevih</p>
          </div>
        </div>
      </div>

      <div class="grid grid-cols-3">
        <dl class="flex items-center">
            <dt class="text-gray-500 dark:text-gray-400 text-sm font-normal me-1">Mala:</dt>
            <dd class="text-gray-900 text-sm dark:text-white font-semibold"><%= @consumption_1_sum %> €</dd>
        </dl>
        <dl class="flex items-center justify-end">
            <dt class="text-gray-500 dark:text-gray-400 text-sm font-normal me-1">Visoka:</dt>
            <dd class="text-gray-900 text-sm dark:text-white font-semibold"><%= @consumption_2_sum %> €</dd>
        </dl>
        <dl class="flex items-center justify-end">
            <dt class="text-gray-500 dark:text-gray-400 text-sm font-normal me-1">Skupaj:</dt>
            <dd class="text-gray-900 text-sm dark:text-white font-semibold"><%= Float.round(@consumption_1_sum + @consumption_2_sum,2) %> €</dd>
        </dl>
      </div>

      <div id="my_chart" phx-hook="ApexChart" data-chart-data={@chart_data_cost}></div>
        <div class="grid grid-cols-1 items-center border-gray-200 border-t dark:border-gray-700 justify-between">
          <div class="flex justify-between items-center pt-5">
            <!-- Button -->
            <button
              id="dropdownDefaultButton"
              data-dropdown-toggle="lastDaysdropdown"
              data-dropdown-placement="bottom"
              class="text-sm font-medium text-gray-500 dark:text-gray-400 hover:text-gray-900 text-center inline-flex items-center dark:hover:text-white"
              type="button">
              Last 7 days
              <svg class="w-2.5 m-2.5 ms-1.5" aria-hidden="true" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 10 6">
                <path stroke="currentColor" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="m1 1 4 4 4-4"/>
              </svg>
            </button>
            <!-- Dropdown menu -->
            <div id="lastDaysdropdown" class="z-10 hidden bg-white divide-y divide-gray-100 rounded-lg shadow w-44 dark:bg-gray-700">
                <ul class="py-2 text-sm text-gray-700 dark:text-gray-200" aria-labelledby="dropdownDefaultButton">
                  <li>
                    <a href="#" class="block px-4 py-2 hover:bg-gray-100 dark:hover:bg-gray-600 dark:hover:text-white">Yesterday</a>
                  </li>
                  <li>
                    <a href="#" class="block px-4 py-2 hover:bg-gray-100 dark:hover:bg-gray-600 dark:hover:text-white">Today</a>
                  </li>
                  <li>
                    <a href="#" class="block px-4 py-2 hover:bg-gray-100 dark:hover:bg-gray-600 dark:hover:text-white">Last 7 days</a>
                  </li>
                  <li>
                    <a href="#" class="block px-4 py-2 hover:bg-gray-100 dark:hover:bg-gray-600 dark:hover:text-white">Last 30 days</a>
                  </li>
                  <li>
                    <a href="#" class="block px-4 py-2 hover:bg-gray-100 dark:hover:bg-gray-600 dark:hover:text-white">Last 90 days</a>
                  </li>
                </ul>
            </div>
          </div>
        </div>
      </div>
    </div>

    """
  end

end
