import { defineConfig } from 'vitepress'

// https://vitepress.dev/reference/site-config
export default defineConfig({
  title: "EOLab - Drones",
  description: "Documentation site on our drone platforms",
  themeConfig: {
    nav: [
      { text: 'Home', link: '/' },
    ],

    sidebar: [
      { items: [{
        text: 'Common Operational Manual',
        link: '/common-operational-manual/README',
        collapsed: false,
        items: [
          { text: 'How to Flash Firmware', link: '/common-operational-manual/flash-firmware'},
          { text: 'How to Charge Batteries', link: '/common-operational-manual/charge-batteries'},
          { text: 'Planning a Campaign', link: '/common-operational-manual/planning-campaign'},
          { text: 'Transmitter Settings', link: '/common-operational-manual/transmitter-settings'},
          { text: 'Flight Modes', link: '/common-operational-manual/flight-modes'},
        ]
      }]},
      {
        text: 'Drones catalog',
        collapsed: true,
        items: [
          { text: 'Platypus', link: '/platypus/README' },
          { text: 'SAR', link: '/sar/README' },
          { text: 'Protoflyer', link: '/protoflyer/README' },
          { text: 'Phoenix', link: '/phoenix/README' },
          { text: 'DJI NEO', link: '/dji-neo/README' },
        ]
      },
      {
        text: 'Components catalog',
        collapsed: true,
        items: [
        ]
      },
      {
        text: 'Development',
        items: [
          {
            text: 'Prerequisities',
            collapsed: true,
            items: [
              {text: 'New', link: ''}
            ]
          },
          { text: 'Add a new firmware', link: 'https://github.com/EOLab-HSRW/drones-fw/blob/main/add.md', target: "_self"},
          { text: 'Hardware Checks', link: '/development/hardware-checks'},
        ]
      }
    ],

    socialLinks: [
      { icon: 'github', link: 'https://github.com/EOLab-HSRW/drones' },
      { icon: 'linkedin', link:  'https://www.linkedin.com/showcase/earth-observation-lab/'},
      { icon: 'pinboard', link: 'https://www.eolab.de/'}
    ]
  },
  rewrites: {
    // use the github README as entry point for the docs
    'README.md': 'index.md',
  }
})
