import type { ApiRouteConfig, ApiRouteHandler } from '@motiadev/core'
import * as route0 from '..\steps\api.step.js'

type RouterPath = {
  stepName: string
  method: 'get' | 'post' | 'put' | 'delete' | 'patch' | 'options' | 'head'
  handler: ApiRouteHandler
  config: ApiRouteConfig
}

export const routerPaths: Record<string, RouterPath> = {
  'POST /basic-tutorial': { stepName: 'ApiTrigger', handler: route0.handler, config: route0.config }
}
