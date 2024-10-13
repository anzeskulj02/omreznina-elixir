defmodule SmartHomeWeb.NetworkTariff.NetworkConsumptionController do

  def consumption_per_day(_start_date, _end_date) do
    url = "https://api.informatika.si/mojelektro/v1/meter-readings"

    #endTime: Date.utc_today()
    params = [
      usagePoint: "3-8008877",
      startTime: "2024-07-01",
      endTime: "2024-07-31",
      option: "ReadingType=32.0.4.1.1.2.12.0.0.0.0.1.0.0.0.3.72.0",
      option: "ReadingType=32.0.4.1.1.2.12.0.0.0.0.2.0.0.0.3.72.0"
    ]
    headers = [
      {"accept", "application/json"},
      {"X-API-TOKEN", "a52f3cb92470463987d8f472d9a469f8"}
    ]

    response = Req.get!(url, headers: headers, params: params)

    # Function to calculate daily consumption for an interval block
    calculate_daily_consumption = fn interval_readings ->
      interval_readings
      |> Enum.chunk_every(2, 1, :discard)
      |> Enum.map(fn [prev, next] ->
        prev_value = Map.get(prev, "value") |> String.to_float()
        next_value = Map.get(next, "value") |> String.to_float()
        %{date: Map.get(next, "timestamp"), consumption: next_value - prev_value}
      end)
    end

    # Process each interval block and associate each result with its corresponding type
    results = response.body["intervalBlocks"]
      |> Enum.with_index()
      |> Enum.map(fn {block, index} ->
        interval_readings = block["intervalReadings"]
        daily_consumptions = calculate_daily_consumption.(interval_readings)
        %{"type" => "Consumption #{index + 1}", "data" => daily_consumptions}
      end)

    transform_data(results)
  end

  def cost_per_day do
    result=consumption_per_day(1,2)

    {multiplied_data, consumption_1_sum, consumption_2_sum} =
      Enum.reduce(result, {[], 0, 0}, fn
        %{name: "Consumption 1", data: values}, {acc, sum1, sum2} ->
          multiplied_values = Enum.map(values, fn %{y: y, x: x} -> %{y: Float.round(y * 0.11511, 2), x: x} end)
          sum1 = Enum.reduce(multiplied_values, sum1, fn %{y: y}, acc -> acc + y end)
          {[ %{name: "Mala tarifa", data: multiplied_values} | acc ], sum1, sum2}

        %{name: "Consumption 2", data: values}, {acc, sum1, sum2} ->
          multiplied_values = Enum.map(values, fn %{y: y, x: x} -> %{y: Float.round(y * 0.16108, 2), x: x} end)
          sum2 = Enum.reduce(multiplied_values, sum2, fn %{y: y}, acc -> acc + y end)
          {[ %{name: "Visoka tarifa", data: multiplied_values} | acc ], sum1, sum2}
      end)

    # Reversing multiplied_data to maintain the original order
    multiplied_data = Enum.reverse(multiplied_data)

    # Output
    {multiplied_data, Float.round(consumption_1_sum, 2), Float.round(consumption_2_sum, 2)}


  end




  def date_to_day(date) do
    {:ok, dt, _} = DateTime.from_iso8601(date)
    DateTime.to_date(dt)
    |> Date.day_of_week()
    |> case do
      1 -> "Pon"
      2 -> "Tor"
      3 -> "Sre"
      4 -> "Čet"
      5 -> "Pet"
      6 -> "Sob"
      7 -> "Ned"
    end
  end

  # Function to transform the data
  def transform_data(consumption_data) do
    Enum.map(consumption_data, fn %{"type" => type, "data" => data} ->
      %{
        name: type,
        data: Enum.map(data, fn data_point ->
          date = Map.get(data_point, :date) || Map.get(data_point, "date")
          consumption = Map.get(data_point, :consumption) || Map.get(data_point, "consumption")

          %{
            x: date_to_day(date),
            y: Float.round(consumption, 2)
          }
        end)
      }
    end)
  end
end
