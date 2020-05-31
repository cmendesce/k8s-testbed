import http from 'k6/http';
import { check } from "k6";


const epochSeconds = () => new Date().getTime() / 1000;

export let options = {
  teardownTimeout: '100s',
  stages: [
      {
        duration: '10s',
        target: 20
      },
      {
        duration: '60s',
        target: 20
      },
      {
        duration: '10s',
        target: 40
      },
      {
        duration: '60s',
        target: 40
      },
      {
        duration: '10s',
        target: 60
      },
      {
        duration: '60s',
        target: 60
      },
      {
        duration: '10s',
        target: 40
      },
      {
        duration: '60s',
        target: 40
      },
      {
        duration: '10s',
        target: 20
    },
    {
        duration: '60s',
        target: 20
    },
    ,
    {
        duration: '10s',
        target: 0
    },
  ]
};

export function setup() {
  return {
    metrics_exporter: `${__ENV.METRICS_EXPORTER_HOST}/exports`,
    start: epochSeconds()
  };
};

export default function (data) {
  const res = http.get('http://nginx-ingress.default.svc/news.php');
  check(res, {
    'status is 200': r => r.status === 200
  });
};

export function teardown(data) {
  data.end = epochSeconds();
  const payload = JSON.stringify({
    start: data.start,
    end: data.end
  });

  const params = {
    headers: {
      'Content-Type': 'application/json',
    },
  };

  const res = http.post(data.metrics_exporter, payload, params);
  console.log(res);
};
