import { defineConfig } from 'vitepress'
import { withMermaid } from "vitepress-plugin-mermaid";

// https://vitepress.dev/reference/site-config
export default withMermaid({
  title: "EOLab - Drones",
  description: "Documentation site on our drone platforms",
  head: [['link', { rel: 'icon', href: '/favicon.ico' }]],
  markdown: {
    math: true
  },
  themeConfig: {
    logo: "https://wiki.eolab.de/lib/exe/fetch.php?media=eolab-logo-minimal.png",
    nav: [
      { text: 'Home', link: '/' },
    ],

    sidebar: [
      { items: [{
        text: 'Introduction',
        link: '/introduction/',
        collapsed: false,
        items: [
          { text: 'Basic Concepts', link: 'https://docs.px4.io/main/en/getting_started/px4_basic_concepts.html'},
        ]
      }]},
      { items: [{
        text: 'Common Operational Manual',
        link: '/common-operational-manual/README',
        collapsed: false,
        items: [
          { text: 'How to Flash Firmware', link: '/common-operational-manual/flash-firmware'},
          { text: 'How to Charge Batteries', link: '/common-operational-manual/charge-batteries'},
          { text: 'Transmitter Settings', link: '/common-operational-manual/transmitter-settings'},
          { text: 'Flight Modes', link: '/common-operational-manual/flight-modes'},
          { text: 'Planning a Campaign', link: '/common-operational-manual/planning-campaign'},
        ]
      }]},
      { items: [{
        text: 'Developers',
        link: '/developers/README',
        collapsed: false,
        items: [
          { text: 'Installation', link: '/developers/install'},
          { text: 'Takeoff and Land (Assignment)', link: '/developers/takeoff-and-land'},
          { text: 'Precision Landing (Assignment)', link: '/developers/precision-landing'},
        ]
      }]},
      {
        items: [{
          text: 'Drones catalog',
          collapsed: true,
          items: [
            { text: 'Platypus', link: '/platypus' },
            { text: 'SAR', link: '/sar' },
            { text: 'Protoflyer', link: '/protoflyer' },
            { text: 'Phoenix', link: '/phoenix' },
            { text: 'Pegasus', link: '/pegasus' },
            { text: 'Condor', link: '/condor' },
            { text: 'DJI NEO', link: '/dji-neo' },
          ]
        }],
      },
      {
        items: [{
          text: 'Technical articles',
          collapsed: true,
          items: [
            { text: 'Multi-Drone Sim', link: '/technical-articles/larasim2025'},
          ]
        }]
      },
      {
        items: [{
          text: 'Experiments',
          collapsed: true,
          items: [
            { text: 'Mesh Network', link: '/experiments/mesh'},
          ]
        }]
      },
      { items: [{
        text: 'Maintainers',
        link: '/maintainers/',
        collapsed: true,
        items: [
          { text: 'Add a new firmware', link: 'https://github.com/EOLab-HSRW/drones-fw/blob/main/add.md', target: "_self"},
          { text: 'Operational Setup', link: '/maintainers/operational-setup'},
          { text: 'Radio Setup', link: '/maintainers/radio-setup'},
          { text: 'Known Issues and Limitations ', link: '/maintainers/issues-and-limitations'},
          {
            text: 'Design Docs',
            collapsed: true,
            link: '/maintainers/design/index.md',
            items: [
              {text: 'Autopilots (firmware)', link: '/maintainers/design/autopilots.md'},
              {text: 'PX4 and ROS 2', link: '/maintainers/design/px4-and-ros2.md'},
            ]
          },
        ]
      }]
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
    'common-operational-manual/': 'index.md',
    'condor/README.md': 'condor/index.md',
    'developers/README.md': 'developers/index.md',
    'dji-neo/README.md': 'dji-neo/index.md',
    'maintainers/README.md': 'maintainers/index.md',
    'phoenix/README.md': 'phoenix/index.md',
    'platypus/README.md': 'platypus/index.md',
    'protoflyer/README.md': 'protoflyer/index.md',
    'sar/README.md': 'sar/index.md',
    'pegasus/README.md': 'pegasus/index.md',
  }
})
