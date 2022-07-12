/*
 * Copyright 2022 NHA
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 * 
 * 
 * This is a Redis Implementation. From the aspect of using it in the future
 * this has been included in the code. Currently, it is not used in the
 * discovery service.
 * 
 * 
 * package in.gov.abdm.uhi.discovery.configuration;
 * 
 * import in.gov.abdm.uhi.discovery.entity.ListofSubscribers; import
 * org.springframework.beans.factory.annotation.Autowired; import
 * org.springframework.boot.autoconfigure.cache.
 * RedisCacheManagerBuilderCustomizer; import
 * org.springframework.context.annotation.Bean; import
 * org.springframework.context.annotation.Configuration; import
 * org.springframework.data.redis.cache.RedisCacheConfiguration; import
 * org.springframework.data.redis.connection.ReactiveKeyCommands; import
 * org.springframework.data.redis.connection.ReactiveRedisConnectionFactory;
 * import org.springframework.data.redis.connection.ReactiveStringCommands;
 * import org.springframework.data.redis.connection.RedisConnectionFactory;
 * import org.springframework.data.redis.core.ReactiveRedisTemplate; import
 * org.springframework.data.redis.serializer.GenericJackson2JsonRedisSerializer;
 * import org.springframework.data.redis.serializer.Jackson2JsonRedisSerializer;
 * import org.springframework.data.redis.serializer.RedisSerializationContext;
 * import org.springframework.data.redis.serializer.StringRedisSerializer;
 * 
 * import javax.annotation.PreDestroy; import java.time.Duration;
 * 
 * @Configuration public class RedisConfig {
 * 
 * @Autowired RedisConnectionFactory factory;
 * 
 * @Bean public ReactiveRedisTemplate<String, ListofSubscribers>
 * reactiveRedisTemplate(ReactiveRedisConnectionFactory factory) {
 * Jackson2JsonRedisSerializer<ListofSubscribers> serializer = new
 * Jackson2JsonRedisSerializer<>(ListofSubscribers.class);
 * RedisSerializationContext.RedisSerializationContextBuilder<String,
 * ListofSubscribers> builder =
 * RedisSerializationContext.newSerializationContext(new
 * StringRedisSerializer()); RedisSerializationContext<String,
 * ListofSubscribers> context = builder.value(serializer) .build(); return new
 * ReactiveRedisTemplate<>(factory, context); }
 * 
 * @Bean public ReactiveKeyCommands keyCommands(final
 * ReactiveRedisConnectionFactory reactiveRedisConnectionFactory) { return
 * reactiveRedisConnectionFactory.getReactiveConnection() .keyCommands(); }
 * 
 * @Bean public ReactiveStringCommands stringCommands(final
 * ReactiveRedisConnectionFactory reactiveRedisConnectionFactory) { return
 * reactiveRedisConnectionFactory.getReactiveConnection() .stringCommands(); }
 * 
 * @PreDestroy public void cleanRedis() { factory.getConnection() .flushDb(); }
 * 
 * @Bean public RedisCacheConfiguration cacheConfiguration() { return
 * RedisCacheConfiguration.defaultCacheConfig()
 * .entryTtl(Duration.ofMinutes(60)) .disableCachingNullValues()
 * .serializeValuesWith(RedisSerializationContext.SerializationPair.
 * fromSerializer(new GenericJackson2JsonRedisSerializer())); }
 * 
 * @Bean public RedisCacheManagerBuilderCustomizer
 * redisCacheManagerBuilderCustomizer() { return (builder) -> builder
 * .withCacheConfiguration("networkRegistryCache",
 * RedisCacheConfiguration.defaultCacheConfig().entryTtl(Duration.ofMinutes(10))
 * );
 * 
 * } }
 */