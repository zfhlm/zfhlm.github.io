
# spring cloud openfeign 自定义错误解码器

### 相关文档

  * 官方文档地址：

        https://docs.spring.io/spring-cloud/docs/current/reference/html/

        https://docs.spring.io/spring-cloud-openfeign/docs/current/reference/html

        https://docs.spring.io/spring-cloud-openfeign/docs/current/reference/html/appendix.html

  * 示例源码地址：

        https://github.com/zfhlm/mrh-example/tree/main/mrh-spring-cloud

### 自定义错误解码器

  * 根据服务响应内容的不同，抛出不同类型的异常：

        可以自定义传递哪些异常信息，默认解码器可能无法满足需求

        根据不同异常信息，抛出不同异常 (开启熔断时可以配置忽略统计某些异常)

### 通用异常和业务异常

  * 自定义状态码(这里只列举主要内容，具体查看源码)：

        public final class ServiceStatus implements Serializable {

            // 成功状态码

            public static final ServiceStatus OK = new ServiceStatus(200, "成功!");

            // http 4xx 状态码

            public static final ServiceStatus HTTP_BAD_REQUEST = new ServiceStatus(400, "请求处理错误!");

            ...

            private static final long serialVersionUID = -8828294891900187085L;

            private final int errcode;

            private final String errmsg;

            private ServiceStatus(int errcode, String errmsg) {
                super();
                if(errmsg == null) {
                    throw new IllegalArgumentException("errmsg");
                }
                this.errcode = errcode;
                this.errmsg = errmsg;
            }

            public ServiceStatus newInstance(String errmsg) {
                return new ServiceStatus(this.errcode, errmsg);
            }

            ....

        }

  * 自定义通用异常：

        public class ServiceStatusException extends RuntimeException {

            private static final long serialVersionUID = -7831210714206422980L;

            private ServiceStatus status;

            public ServiceStatusException(ServiceStatus status) {
                super();
                this.status = status;
            }

            public ServiceStatusException(ServiceStatus status, String message) {
                super(message);
                this.status = status;
            }

            public ServiceStatusException(ServiceStatus status, Throwable cause) {
                super(cause);
                this.status = status;
            }

            public ServiceStatus getStatus() {
                return status;
            }

        }

  * 自定义业务异常：

        public class ServiceBusinessException extends ServiceStatusException {

            private static final long serialVersionUID = -6858131776792113970L;

            public ServiceBusinessException(ServiceStatus status, String message) {
                super(status, message);
            }

            public ServiceBusinessException(ServiceStatus status, Throwable cause) {
                super(status, cause);
            }

            public ServiceBusinessException(ServiceStatus status) {
                super(status);
            }

        }

### 自定义错误解码器

  * 定义服务异常响应 body 信息：

        public class InnerServerErrorBody implements Serializable {

            private static final long serialVersionUID = -5482255815368673558L;

            private ServiceStatus status;

            private boolean isBusiness;

            public InnerServerErrorBody(ServiceStatus status, boolean isBusiness) {
                super();
                this.status = status;
                this.isBusiness = isBusiness;
            }

            public ServiceStatus getStatus() {
                return status;
            }

            public void setStatus(ServiceStatus status) {
                this.status = status;
            }

            public boolean isBusiness() {
                return isBusiness;
            }

            public void setBusiness(boolean isBusiness) {
                this.isBusiness = isBusiness;
            }

        }

  * 创建 openfeign 错误解码器：

        public class InnerServerErrorBodyDecoderFactory extends ErrorDecoder.Default implements FeignErrorDecoderFactory {

            @Override
            public ErrorDecoder create(Class<?> type) {
                return this;
            }

            @Override
            public Exception decode(String methodKey, Response response) {

                FeignException cause = (FeignException)super.decode(methodKey, response);

                if(cause instanceof FeignServerException) {
                    if(cause instanceof FeignException.InternalServerError) {
                        byte[] body = cause.responseBody().map(ByteBuffer::array).orElse(null);
                        if(body != null) {
                            try {
                                // 根据响应内容，决定是否返回业务异常
                                InnerServerErrorBody errorBody = (InnerServerErrorBody)SerializationUtils.deserialize(body);
                                if(errorBody.isBusiness()) {
                                    return new ServiceBusinessException(errorBody.getStatus(), methodKey);
                                } else {
                                    return new ServiceStatusException(errorBody.getStatus(), methodKey);
                                }
                            } catch (Exception ex) {}
                        }
                        return new ServiceStatusException(ServiceStatus.HTTP_INTERNAL_SERVER_ERROR, cause);
                    }
                    // 非业务异常
                    else if(cause instanceof FeignException.BadGateway) {
                        return new ServiceStatusException(ServiceStatus.HTTP_BAD_GATEWAY, cause);
                    }
                    // 非业务异常
                    else if(cause instanceof FeignException.GatewayTimeout) {
                        return new ServiceStatusException(ServiceStatus.HTTP_GATEWAY_TIMEOUT, cause);
                    }
                    // 非业务异常
                    else if(cause instanceof FeignException.NotImplemented) {
                        return new ServiceStatusException(ServiceStatus.HTTP_NOT_IMPLEMENTED, cause);
                    }
                    // 非业务异常
                    else if(cause instanceof FeignException.ServiceUnavailable) {
                        return new ServiceStatusException(ServiceStatus.HTTP_SERVICE_UNAVAILABLE, cause);
                    }
                }
                else if(cause instanceof FeignClientException) {
                    if(cause instanceof FeignException.BadRequest) {
                        return new ServiceBusinessException(ServiceStatus.HTTP_BAD_REQUEST, cause);
                    }
                    else if(cause instanceof FeignException.Conflict) {
                        return new ServiceBusinessException(ServiceStatus.HTTP_CONFLICT, cause);
                    }
                    else if(cause instanceof FeignException.Forbidden) {
                        return new ServiceBusinessException(ServiceStatus.HTTP_FORBIDDEN, cause);
                    }
                    else if(cause instanceof FeignException.Gone) {
                        return new ServiceBusinessException(ServiceStatus.HTTP_GONE, cause);
                    }
                    else if(cause instanceof FeignException.MethodNotAllowed) {
                        return new ServiceBusinessException(ServiceStatus.HTTP_METHOD_NOT_ALLOWED, cause);
                    }
                    else if(cause instanceof FeignException.NotAcceptable) {
                        return new ServiceBusinessException(ServiceStatus.HTTP_NOT_ACCEPTABLE, cause);
                    }
                    else if(cause instanceof FeignException.NotFound) {
                        return new ServiceBusinessException(ServiceStatus.HTTP_NOT_FOUND, cause);
                    }
                    // 非业务异常
                    else if(cause instanceof FeignException.TooManyRequests) {
                        return new ServiceStatusException(ServiceStatus.EXTEND_SERVER_BUSY_ERRROR, cause);
                    }
                    else if(cause instanceof FeignException.Unauthorized) {
                        return new ServiceBusinessException(ServiceStatus.HTTP_UNAUTHORIZED, cause);
                    }
                    else if(cause instanceof FeignException.UnprocessableEntity) {
                        return new ServiceBusinessException(ServiceStatus.HTTP_UNPROCESSABLE_ENTITY, cause);
                    }
                    else if(cause instanceof FeignException.UnsupportedMediaType) {
                        return new ServiceBusinessException(ServiceStatus.HTTP_UNSUPPORTED_MEDIA_TYPE, cause);
                    }
                }
                // 非业务异常
                else if(cause instanceof RetryableException) {
                    return new ServiceStatusException(ServiceStatus.HTTP_SERVICE_UNAVAILABLE, cause);
                }
                else if(cause instanceof EncodeException) {
                    return new ServiceBusinessException(ServiceStatus.HTTP_BAD_REQUEST, cause);
                }
                else if(cause instanceof DecodeException) {
                    return new ServiceBusinessException(ServiceStatus.HTTP_BAD_REQUEST, cause);
                }

                return cause;
            }

        }

### 服务提供方传递异常

  * 服务实现方，定义全局异常处理器：

        @ControllerAdvice
        public class GlobalControllerAdvice {

            private final Log log = LogFactory.getLog(getClass());

            @ExceptionHandler(Throwable.class)
            @ResponseStatus(HttpStatus.INTERNAL_SERVER_ERROR)
            public ResponseEntity<byte[]> handle(Throwable cause) {

                log.error(cause.getMessage(), cause);

                Supplier<InnerServerErrorBody> builder = () -> {
                    // 状态码异常
                    if(cause instanceof ServiceStatusException) {
                        return new InnerServerErrorBody(((ServiceStatusException)cause).getStatus(), Boolean.TRUE);
                    }
                    // 参数绑定错误
                    else if(cause instanceof BindException) {
                        return new InnerServerErrorBody(ServiceStatus.EXTEND_PARAM_BIND_ERROR, Boolean.TRUE);
                    }
                    // 参数验证错误
                    else if(cause instanceof MethodArgumentNotValidException) {
                        return new InnerServerErrorBody(ServiceStatus.EXTEND_PARAM_VALID_ERROR, Boolean.TRUE);
                    }
                    // 参数解析错误
                    else if(cause instanceof HttpMessageConversionException) {
                        return new InnerServerErrorBody(ServiceStatus.EXTEND_PARAM_RESOLVE_ERROR, Boolean.TRUE);
                    }
                    // 请求接口不存在
                    else if(cause instanceof NoHandlerFoundException) {
                        return new InnerServerErrorBody(ServiceStatus.HTTP_NOT_FOUND, Boolean.TRUE);
                    }
                    // 请求方法错误
                    else if(cause instanceof HttpRequestMethodNotSupportedException) {
                        return new InnerServerErrorBody(ServiceStatus.HTTP_METHOD_NOT_ALLOWED, Boolean.TRUE);
                    }
                    // 请求头缺失
                    else if(cause instanceof MissingRequestHeaderException) {
                        return new InnerServerErrorBody(ServiceStatus.EXTEND_MISSING_HEADER_ERROR, Boolean.TRUE);
                    }
                    // 熔断异常，不往上传递
                    else if(cause instanceof CallNotPermittedException) {
                        return new InnerServerErrorBody(ServiceStatus.EXTEND_SERVER_BUSY_ERRROR, Boolean.TRUE);
                    }
                    // 超时异常，不往上传递
                    else if(cause instanceof TimeoutException) {
                        return new InnerServerErrorBody(ServiceStatus.HTTP_REQUEST_TIMEOUT, Boolean.TRUE);
                    }
                    // 其他错误，非业务异常
                    else {
                        return new InnerServerErrorBody(ServiceStatus.EXTEND_SERVER_ERROR, Boolean.FALSE);
                    }
                };

                return new ResponseEntity<byte[]>(SerializationUtils.serialize(builder.get()), HttpStatus.INTERNAL_SERVER_ERROR);

            }

        }

### 服务调用方接收异常

  * 注册 openfeign 自定义错误解码器：

        @Configuration
        public class FallbackConfiguration {

            @Bean
            public InnerServerErrorBodyDecoderFactory feignInnerServerErrorBodyDecoderFactory() {
                return new InnerServerErrorBodyDecoderFactory();
            }

        }
