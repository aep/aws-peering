// Example of minimal DHCP server:
package main

import (
	dhcp "github.com/krolaw/dhcp4"

	"log"
	"net"
	"time"
    "os"
)

// Example using DHCP with a single network interface device
func main() {
	handler := &DHCPHandler{
		serverIp:  net.IP{172, 30, 0, 1},
        clientIp:  net.IP{172, 30, 0, 2},
		options: dhcp.Options{
			dhcp.OptionSubnetMask:       []byte{255, 255, 255, 0},
		},
	}
	log.Fatal(dhcp.ListenAndServeIf(os.Args[1],handler)) // Select interface on multi interface device
}

type DHCPHandler struct {
	serverIp    net.IP
    clientIp    net.IP
	options     dhcp.Options
}

func (h *DHCPHandler) ServeDHCP(p dhcp.Packet, msgType dhcp.MessageType, options dhcp.Options) (d dhcp.Packet) {
	switch msgType {

	case dhcp.Discover:
		return dhcp.ReplyPacket(p, dhcp.Offer, h.serverIp, h.clientIp, time.Hour,
			h.options.SelectOrderOrAll(options[dhcp.OptionParameterRequestList]))

	case dhcp.Request:
		if server, ok := options[dhcp.OptionServerIdentifier]; ok && !net.IP(server).Equal(h.serverIp) {
			return nil // Message not for this dhcp server
		}
		reqIP := net.IP(options[dhcp.OptionRequestedIPAddress])
		if reqIP == nil {
			reqIP = net.IP(p.CIAddr())
		}

        if reqIP.Equal(h.clientIp) {
            return dhcp.ReplyPacket(p, dhcp.ACK, h.serverIp, reqIP, time.Hour,
            h.options.SelectOrderOrAll(options[dhcp.OptionParameterRequestList]))
        } else {
            return dhcp.ReplyPacket(p, dhcp.NAK, h.serverIp, nil, 0, nil)
        }
	}
	return nil
}

