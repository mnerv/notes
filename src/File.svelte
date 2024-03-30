<script lang="ts">
  import { onMount } from "svelte";
  import Icon from '@iconify/svelte';
  export let title: string
  export let level: number = 0
  export let href: string = ''
  export let info: string = ''
  export let isExpand: boolean = false
  const indent = 8
  let element: HTMLElement

  onMount(() => {
    const css = window.getComputedStyle(element)
    const padding = css.getPropertyValue('padding').split(' ')
    element.style.paddingLeft = `${parseFloat(padding[1].replace('px', '')) * (level + 1) + level * indent}px`
  })
</script>

{#if href !== ''}
  <div bind:this={element} class="w-full px-3 py-2 md:px-2 md:py-1 flex">
    <a href="{href}" class="hover:underline overflow-clip flex-grow">{title}</a>
    <span class="my-auto px-1 text-gray-400">
      <Icon icon="bi:file-earmark-pdf"/>
    </span>
  </div>
{:else}
  <button on:click bind:this={element} class="dark:hover:bg-zinc-600 hover:bg-zinc-200 w-full px-3 py-2 md:px-2 md:py-1 text-left flex">
    <span class="my-auto w-4 mr-1">
      {#if isExpand}
        <Icon icon="tabler:chevron-down"/>
      {:else}
        <Icon icon="tabler:chevron-right"/>
      {/if}
    </span>
    <span class="flex-grow">{title}</span>
    <span class="px-2 text-xs m-auto">
      {info}
    </span>
  </button>
{/if}
