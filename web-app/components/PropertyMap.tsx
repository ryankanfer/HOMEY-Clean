'use client';

import { useState, useCallback, useRef, useEffect } from 'react';
import Map, { Marker, Popup, NavigationControl, GeolocateControl } from 'react-map-gl/mapbox';
import type { Listing } from '@/lib/types';
import 'mapbox-gl/dist/mapbox-gl.css';

interface PropertyMapProps {
  listings: Listing[];
  onMarkerClick?: (listing: Listing) => void;
  initialViewState?: {
    latitude: number;
    longitude: number;
    zoom: number;
  };
}

export default function PropertyMap({
  listings,
  onMarkerClick,
  initialViewState = {
    latitude: 40.7128, // NYC default
    longitude: -74.0060,
    zoom: 11,
  },
}: PropertyMapProps) {
  const [selectedListing, setSelectedListing] = useState<Listing | null>(null);
  const [viewState, setViewState] = useState(initialViewState);
  const mapRef = useRef<any>();

  // Calculate bounds to fit all listings
  useEffect(() => {
    if (listings.length > 0 && mapRef.current) {
      const bounds = listings.reduce(
        (acc, listing) => {
          return {
            minLat: Math.min(acc.minLat, listing.latitude),
            maxLat: Math.max(acc.maxLat, listing.latitude),
            minLng: Math.min(acc.minLng, listing.longitude),
            maxLng: Math.max(acc.maxLng, listing.longitude),
          };
        },
        {
          minLat: listings[0].latitude,
          maxLat: listings[0].latitude,
          minLng: listings[0].longitude,
          maxLng: listings[0].longitude,
        }
      );

      // Fit map to bounds with padding
      try {
        mapRef.current?.fitBounds(
          [
            [bounds.minLng, bounds.minLat],
            [bounds.maxLng, bounds.maxLat],
          ],
          {
            padding: 50,
            duration: 1000,
          }
        );
      } catch (err) {
        console.warn('Failed to fit bounds:', err);
      }
    }
  }, [listings]);

  const formatPrice = (price: number) => {
    return new Intl.NumberFormat('en-US', {
      style: 'currency',
      currency: 'USD',
      maximumFractionDigits: 0,
    }).format(price);
  };

  const handleMarkerClick = useCallback((listing: Listing) => {
    setSelectedListing(listing);
    if (onMarkerClick) {
      onMarkerClick(listing);
    }
  }, [onMarkerClick]);

  // Mapbox token - will work without it in demo mode
  const MAPBOX_TOKEN = process.env.NEXT_PUBLIC_MAPBOX_TOKEN || '';

  if (!MAPBOX_TOKEN) {
    // Fallback UI when no token
    return (
      <div className="w-full h-full flex items-center justify-center bg-gradient-to-br from-primary/20 to-purple-600/20 rounded-2xl">
        <div className="text-center p-6">
          <div className="text-6xl mb-4">🗺️</div>
          <h3 className="text-white font-bold mb-2">Map View</h3>
          <p className="text-white/60 text-sm mb-4">
            Add NEXT_PUBLIC_MAPBOX_TOKEN to .env.local to enable maps
          </p>
          <a
            href="https://account.mapbox.com/access-tokens/"
            target="_blank"
            rel="noopener noreferrer"
            className="px-4 py-2 bg-primary text-white rounded-full text-sm font-semibold inline-block hover:bg-primary/90 transition-colors"
          >
            Get Free Token
          </a>
          <div className="mt-4 text-white/40 text-xs">
            {listings.length} properties ready to display
          </div>
        </div>
      </div>
    );
  }

  return (
    <Map
      ref={mapRef}
      {...viewState}
      onMove={evt => setViewState(evt.viewState)}
      mapboxAccessToken={MAPBOX_TOKEN}
      style={{ width: '100%', height: '100%' }}
      mapStyle="mapbox://styles/mapbox/dark-v11"
      attributionControl={false}
    >
      {/* Controls */}
      <NavigationControl position="top-right" />
      <GeolocateControl position="top-right" />

      {/* Property Markers */}
      {listings.map((listing) => (
        <Marker
          key={listing.id}
          latitude={listing.latitude}
          longitude={listing.longitude}
          anchor="bottom"
          onClick={(e) => {
            e.originalEvent.stopPropagation();
            handleMarkerClick(listing);
          }}
        >
          <div className="relative group cursor-pointer">
            {/* Price Pin */}
            <div className="bg-white text-black px-3 py-1.5 rounded-full font-bold text-sm shadow-lg group-hover:scale-110 transition-transform whitespace-nowrap">
              {formatPrice(listing.price)}
            </div>
            {/* Arrow */}
            <div className="absolute left-1/2 -translate-x-1/2 top-full w-0 h-0 border-l-[6px] border-l-transparent border-r-[6px] border-r-transparent border-t-[8px] border-t-white"></div>
          </div>
        </Marker>
      ))}

      {/* Popup on marker click */}
      {selectedListing && (
        <Popup
          latitude={selectedListing.latitude}
          longitude={selectedListing.longitude}
          anchor="bottom"
          onClose={() => setSelectedListing(null)}
          closeButton={true}
          closeOnClick={false}
          offset={25}
          className="property-popup"
        >
          <div className="p-0 min-w-[250px]">
            {/* Image */}
            {selectedListing.thumbnail_url && (
              <img
                src={selectedListing.thumbnail_url}
                alt={selectedListing.address}
                className="w-full h-32 object-cover rounded-t"
              />
            )}

            {/* Details */}
            <div className="p-3">
              <div className="font-bold text-lg mb-1">
                {formatPrice(selectedListing.price)}
                {selectedListing.listing_type === 'rental' && (
                  <span className="text-xs text-gray-500 font-normal">/mo</span>
                )}
              </div>
              <div className="text-sm text-gray-700 mb-1">{selectedListing.address}</div>
              <div className="text-xs text-gray-500 mb-2">{selectedListing.neighborhood}</div>
              <div className="flex gap-3 text-xs text-gray-600">
                <span>
                  {selectedListing.bedrooms === 0
                    ? 'Studio'
                    : `${selectedListing.bedrooms} bed`}
                </span>
                <span>•</span>
                <span>{selectedListing.bathrooms} bath</span>
                {selectedListing.square_footage && (
                  <>
                    <span>•</span>
                    <span>{selectedListing.square_footage.toLocaleString()} sqft</span>
                  </>
                )}
              </div>
            </div>
          </div>
        </Popup>
      )}
    </Map>
  );
}
