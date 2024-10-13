import ApexCharts from "apexcharts"
let Hooks = {};

Hooks.ApexChart = {
  mounted() {
    let chartData = JSON.parse(this.el.dataset.chartData);

    this.chart = new ApexCharts(this.el, chartData);
    this.chart.render();
  },
  updated() {
    let chartData = JSON.parse(this.el.dataset.chartData);
    this.chart.updateOptions(chartData);
  },
  destroyed() {
    this.chart.destroy();
  }
};

export default Hooks;