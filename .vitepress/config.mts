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
      { text: 'Common Manual', link: '/common-manual/README'},
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
