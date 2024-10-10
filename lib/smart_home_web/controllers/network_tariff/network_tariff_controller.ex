defmodule SmartHomeWeb.NetworkTariff.NetworkTariffController do

  def get_entity_data do
    date = DateTime.utc_now()
    current_hour = date.hour
    year = date.year
    month = date.month

    {easter_saturday, easter_monday} = calculate_easter_related_holidays(year)

    is_high_season = month in [11, 12, 1, 2]
    weekend_or_holiday = is_weekend_or_holiday(date, easter_saturday, easter_monday)

    tariffs = [
      {0..5, {3, 4}, {5, 4}},   # Early morning
      {6..6, {2, 3}, {4, 3}},   # 6 AM
      {7..13, {1, 2}, {3, 2}},  # Morning to early afternoon
      {14..15, {2, 3}, {4, 3}}, # Early afternoon
      {16..19, {1, 2}, {3, 2}}, # Late afternoon to early evening
      {20..21, {2, 3}, {4, 3}}, # Evening
      {22..23, {3, 4}, {5, 4}}  # Late evening
    ]

    blocks = for hour <- 0..23 do
      Enum.find_value(tariffs, fn {range, high_season, low_season} ->
        if hour in range do
          cond do
            is_high_season and not weekend_or_holiday -> elem(high_season, 0)
            not is_high_season and weekend_or_holiday -> elem(low_season, 0)
            is_high_season -> elem(high_season, 1)
            true -> elem(low_season, 1)
          end
        end
      end) || 0
    end

    current_tariff = Enum.at(blocks, current_hour)
    IO.inspect(blocks)
    IO.inspect(current_tariff)
    %{
      state: "Active",
      current_tariff: current_tariff,
      blocks: blocks
    }
  end

  defp calculate_easter_related_holidays(year) do
    a = rem(year, 19)
    b = div(year, 100)
    c = rem(year, 100)
    d = div(b, 4)
    e = rem(b, 4)
    f = div(b + 8, 25)
    g = div(b - f + 1, 3)
    h = rem(19 * a + b - d - g + 15, 30)
    i = div(c, 4)
    k = rem(c, 4)
    l = rem(32 + 2 * e + 2 * i - h - k, 7)
    m = div(a + 11 * h + 22 * l, 451)
    month = div(h + l - 7 * m + 114, 31)
    day = rem(h + l - 7 * m + 114, 31) + 1

    {:ok, easter_sunday} = Date.new(year, month, day)
    easter_saturday = Date.add(easter_sunday, -1)
    easter_monday = Date.add(easter_sunday, 1)

    {easter_saturday, easter_monday}
  end

  defp is_weekend_or_holiday(date, easter_saturday, easter_monday) do
    fixed_holidays = [
      {1, 1}, {1, 2}, {2, 8}, {4, 27},
      {5, 1}, {5, 2}, {6, 25}, {8, 15},
      {10, 31}, {11, 1}, {12, 25}, {12, 26}
    ]

    day_of_week = Date.day_of_week(date)
    {month, day} = {date.month, date.day}

    is_weekend = day_of_week in [6, 7]
    is_fixed_holiday = {month, day} in fixed_holidays
    is_easter_related_holiday = {month, day} == {easter_saturday.month, easter_saturday.day} ||
                               {month, day} == {easter_monday.month, easter_monday.day}

    is_weekend or is_fixed_holiday or is_easter_related_holiday
  end

  def generate_segments(config, blocks) do
    total_segments = 24
    outer_radius = config.outer_radius
    inner_radius = config.inner_radius
    angle = 2 * :math.pi / total_segments

    for i <- 0..(total_segments - 1) do
      segment_value = Enum.at(blocks, i)
      segment_color = Map.get(config.color_map, segment_value, "#000000")
      path = generate_segment_path(i, angle, outer_radius, inner_radius, segment_color)
      text = if config.show_hours, do: generate_segment_text(i, angle, outer_radius), else: nil
      [path, text]
    end
  end

  defp generate_segment_path(index, angle, outer_radius, inner_radius, color) do
    x1 = 50 + outer_radius * :math.cos(index * angle - :math.pi / 2)
    y1 = 50 + outer_radius * :math.sin(index * angle - :math.pi / 2)
    x2 = 50 + outer_radius * :math.cos((index + 1) * angle - :math.pi / 2)
    y2 = 50 + outer_radius * :math.sin((index + 1) * angle - :math.pi / 2)
    x3 = 50 + inner_radius * :math.cos((index + 1) * angle - :math.pi / 2)
    y3 = 50 + inner_radius * :math.sin((index + 1) * angle - :math.pi / 2)
    x4 = 50 + inner_radius * :math.cos(index * angle - :math.pi / 2)
    y4 = 50 + inner_radius * :math.sin(index * angle - :math.pi / 2)

    """
    <path
      d="M#{x1},#{y1} A#{outer_radius},#{outer_radius} 0 0,1 #{x2},#{y2}
         L#{x3},#{y3} A#{inner_radius},#{inner_radius} 0 0,0 #{x4},#{y4} Z"
      fill="#{color}" stroke="rgba(0, 0, 0, 1)" stroke-width="0.3"
    />
    """
  end

  defp generate_segment_text(index, angle, outer_radius) do
    label_radius = outer_radius + 5
    label_x = 50 + label_radius * :math.cos((index + 0.5) * angle - :math.pi / 2)
    label_y = 50 + label_radius * :math.sin((index + 0.5) * angle - :math.pi / 2)

    """
    <text x="#{label_x}" y="#{label_y}" fill="rgba(150, 150, 150, 1)" font-size="5" text-anchor="middle" alignment-baseline="middle">
      #{index + 1}
    </text>
    """
  end

  def current_hour_segment(current_hour, outer_radius, inner_radius, config, current_block) do
    outer_radius = outer_radius - 10
    inner_radius = inner_radius - 7
    total_segments = 24
    angle = 2 * :math.pi / total_segments

    x1 = 50 + outer_radius * :math.cos(current_hour * angle - :math.pi / 2)
    y1 = 50 + outer_radius * :math.sin(current_hour * angle - :math.pi / 2)
    x2 = 50 + outer_radius * :math.cos((current_hour + 1) * angle - :math.pi / 2)
    y2 = 50 + outer_radius * :math.sin((current_hour + 1) * angle - :math.pi / 2)
    x3 = 50 + inner_radius * :math.cos((current_hour + 1) * angle - :math.pi / 2)
    y3 = 50 + inner_radius * :math.sin((current_hour + 1) * angle - :math.pi / 2)
    x4 = 50 + inner_radius * :math.cos(current_hour * angle - :math.pi / 2)
    y4 = 50 + inner_radius * :math.sin(current_hour * angle - :math.pi / 2)

    segment_color = Map.get(config.color_map , current_block, "#000000")
    IO.inspect(segment_color)

    """
    <path
      d="M#{x1},#{y1} A#{outer_radius},#{outer_radius} 0 0,1 #{x2},#{y2}
         L#{x3},#{y3} A#{inner_radius},#{inner_radius} 0 0,0 #{x4},#{y4} Z"
      fill=#{segment_color} stroke="none"
    />
    """
  end
end
