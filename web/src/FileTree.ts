export type NodeT = {
  key: string
  name: string,
  level: number,
  href: string,
  parent: NodeT | null
  children: NodeT[]
}

export function sortByType(list: NodeT[]): NodeT[] {
  const directory = list.filter(a => a.href === '')
  const files = list.filter(a => a.href !== '')
  return [...directory, ...files]
}

export function sortByName(list: NodeT[]): NodeT[] {
  return list.sort()
}

// Trie: https://en.wikipedia.org/wiki/Trie
function findNodeT(tree: NodeT[], key: string): NodeT | null {
  for (const node of tree) {
    if (node.key === key) return node
    const search = findNodeT(node.children, key)
    if (search) return search
  }
  return null
}

function pushNodeT(tree: NodeT[], node: NodeT): NodeT {
  let search: NodeT | null = null
  if (node.parent)
    search = findNodeT(tree, node.parent.key)

  if (search) {
    const parent = search
    search = findNodeT(tree, node.key)
    if (!search) parent.children.push(node)
    node.parent = parent
  } else {
    search = findNodeT(tree, node.key)
    if (!search) tree.push(node)
  }
  return node
}

export function pathsToFileTree(paths: string[]): NodeT[] {
  const tree: NodeT[] = []

  for (const path of paths) {
    const sep = path.split('/').filter(txt => txt !== '' && txt !== 'pdf')
    let key = ''
    let parent: NodeT | null = null
    for (let i = 0; i < sep.length; ++i) {
      key += '/' + sep[i]
      // const name = sep[i].split('_')
      //              .map(v => v[0].toUpperCase() + v.slice(1, v.length)).join(' ')
      //              .split('-').map(v => v[0].toUpperCase() + v.slice(1, v.length)).join('. ')
      const name = sep[i]
      const node: NodeT = {
        key: key,
        name: name,
        level: i,
        href: i === sep.length - 1 ? path : '',
        parent: parent,
        children: []
      }
      parent = pushNodeT(tree, node)
    }
  }
  return tree
}
