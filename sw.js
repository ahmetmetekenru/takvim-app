// Kurulabilir uygulama için gereken basit service worker.
// Sadece kabuğun kendi dosyalarını saklar; takvim verisi her zaman Google'dan gelir.
const CACHE_NAME = "takvim-app-v1";

self.addEventListener("fetch", (event) => {
  const sameOrigin = new URL(event.request.url).origin === self.location.origin;
  if (event.request.method !== "GET" || !sameOrigin) return;

  event.respondWith(
    fetch(event.request)
      .then((response) => {
        const copy = response.clone();
        caches.open(CACHE_NAME).then((cache) => cache.put(event.request, copy));
        return response;
      })
      .catch(() => caches.match(event.request))
  );
});
