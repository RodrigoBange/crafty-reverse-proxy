package proxy

import (
	"fmt"
	"net"
)

// IPFilter holds a list of allowed networks.
type IPFilter struct {
	allowedNets []*net.IPNet
}

// NewIPFilter parses a list of CIDR strings into an IPFilter.
func NewIPFilter(cidrs []string) (*IPFilter, error) {
	var nets []*net.IPNet
	for _, cidr := range cidrs {
		_, network, err := net.ParseCIDR(cidr)
		if err != nil {
			return nil, fmt.Errorf("invalid CIDR %q: %w", cidr, err)
		}
		nets = append(nets, network)
	}
	return &IPFilter{allowedNets: nets}, nil
}

// Allow returns true if ip is in any of the allowed networks.
func (f *IPFilter) Allow(ip net.IP) bool {
	for _, network := range f.allowedNets {
		if network.Contains(ip) {
			return true
		}
	}
	return false
}
