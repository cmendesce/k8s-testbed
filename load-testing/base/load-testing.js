import http from 'k6/http';

export default function (data) {
  const response = http.get("https://test-api.k6.io/");
};
