/*  Copyright (c) 2006-2007, Philip Busch <broesel@studcs.uni-sb.de>
 *  All rights reserved.
 *
 *  Redistribution and use in source and binary forms, with or without
 *  modification, are permitted provided that the following conditions are met:
 *
 *   - Redistributions of source code must retain the above copyright notice,
 *     this list of conditions and the following disclaimer.
 *   - Redistributions in binary form must reproduce the above copyright
 *     notice, this list of conditions and the following disclaimer in the
 *     documentation and/or other materials provided with the distribution.
 *
 *  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 *  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 *  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 *  ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
 *  LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 *  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 *  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 *  INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 *  CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 *  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 *  POSSIBILITY OF SUCH DAMAGE.
 */

/**
 * @file
 * Base64 implementation.
 * @ingroup base64
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "cencode.h"

#define XX 100

/** @var base64_list
 *   A 64 character alphabet.
 *
 *   A 64-character subset of International Alphabet IA5, enabling
 *   6 bits to be represented per printable character.  (The proposed
 *   subset of characters is represented identically in IA5 and ASCII.)
 *   The character "=" signifies a special processing function used for
 *   padding within the printable encoding procedure.
 *
 *   \verbatim
 Value Encoding  Value Encoding  Value Encoding  Value Encoding
 0 A            17 R            34 i            51 z
 1 B            18 S            35 j            52 0
 2 C            19 T            36 k            53 1
 3 D            20 U            37 l            54 2
 4 E            21 V            38 m            55 3
 5 F            22 W            39 n            56 4
 6 G            23 X            40 o            57 5
 7 H            24 Y            41 p            58 6
 8 I            25 Z            42 q            59 7
 9 J            26 a            43 r            60 8
 10 K            27 b            44 s            61 9
 11 L            28 c            45 t            62 +
 12 M            29 d            46 u            63 /
 13 N            30 e            47 v
 14 O            31 f            48 w         (pad) =
 15 P            32 g            49 x
 16 Q            33 h            50 y
 \endverbatim
 */
static const char base64_list[] = \
"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

static const int base64_index[256] = {
    XX,XX,XX,XX, XX,XX,XX,XX, XX,XX,XX,XX, XX,XX,XX,XX,
    XX,XX,XX,XX, XX,XX,XX,XX, XX,XX,XX,XX, XX,XX,XX,XX,
    XX,XX,XX,XX, XX,XX,XX,XX, XX,XX,XX,62, XX,XX,XX,63,
    52,53,54,55, 56,57,58,59, 60,61,XX,XX, XX,XX,XX,XX,
    XX, 0, 1, 2,  3, 4, 5, 6,  7, 8, 9,10, 11,12,13,14,
    15,16,17,18, 19,20,21,22, 23,24,25,XX, XX,XX,XX,XX,
    XX,26,27,28, 29,30,31,32, 33,34,35,36, 37,38,39,40,
    41,42,43,44, 45,46,47,48, 49,50,51,XX, XX,XX,XX,XX,
    XX,XX,XX,XX, XX,XX,XX,XX, XX,XX,XX,XX, XX,XX,XX,XX,
    XX,XX,XX,XX, XX,XX,XX,XX, XX,XX,XX,XX, XX,XX,XX,XX,
    XX,XX,XX,XX, XX,XX,XX,XX, XX,XX,XX,XX, XX,XX,XX,XX,
    XX,XX,XX,XX, XX,XX,XX,XX, XX,XX,XX,XX, XX,XX,XX,XX,
    XX,XX,XX,XX, XX,XX,XX,XX, XX,XX,XX,XX, XX,XX,XX,XX,
    XX,XX,XX,XX, XX,XX,XX,XX, XX,XX,XX,XX, XX,XX,XX,XX,
    XX,XX,XX,XX, XX,XX,XX,XX, XX,XX,XX,XX, XX,XX,XX,XX,
    XX,XX,XX,XX, XX,XX,XX,XX, XX,XX,XX,XX, XX,XX,XX,XX,
};

/** Encode a minimal memory block. This function encodes a minimal memory area
 *  of three bytes into a printable base64-format sequence of four bytes.
 *  It is mainly used in more convenient functions, see below.
 *
 * @attention This function can't check if there's enough space at the memory
 *            memory location pointed to by \c out, so be careful.
 *
 * @param out pointer to destination
 * @param in pointer to source
 * @param len input size in bytes (between 0 and 3)
 * @returns nothing
 *
 * @ingroup base64
 */
void base64_encode_block(unsigned char out[4], const unsigned char in[3], int len)
{
	out[0] = base64_list[ in[0] >> 2 ];
	out[1] = base64_list[ ((in[0] & 0x03) << 4) | ((in[1] & 0xf0) >> 4) ];
	out[2] = (unsigned char) (len > 1 ? base64_list[ ((in[1] & 0x0f) << 2) | ((in[2] & 0xc0) >> 6) ] : '=');
	out[3] = (unsigned char) (len > 2 ? base64_list[in[2] & 0x3f] : '=');
}

/** Decode a minimal memory block. This function decodes a minimal memory area
 *  of four bytes into its decoded equivalent. It is mainly used in more
 *  convenient functions, see below.
 *
 * @attention This function can't check if there's enough space at the memory
 *            memory location pointed to by \c out, so be careful.
 *
 * @param out pointer to destination
 * @param in pointer to source
 * @returns -1 on error (illegal character) or the number of bytes decoded
 *
 * @ingroup base64
 */
int base64_decode_block(unsigned char out[3], const unsigned char in[4])
{
	int i, numbytes = 3;
	char tmp[4];
	
	for(i = 3; i >= 0; i--) {
		if(in[i] == '=') {
			tmp[i] = 0;
			numbytes = i - 1;
		} else {
			tmp[i] = base64_index[ (unsigned char)in[i] ];
		}
		
		if(tmp[i] == XX)
			return(-1);
	}
	
	out[0] = (unsigned char) (  tmp[0] << 2 | tmp[1] >> 4);
	out[1] = (unsigned char) (  tmp[1] << 4 | tmp[2] >> 2);
	out[2] = (unsigned char) (((tmp[2] << 6) & 0xc0) | tmp[3]);
	
	return(numbytes);
}

/** Compute size of needed storage for encoding. This function computes the
 *  \e exact size of a memory area needed to hold the result of an encoding
 *  operation, not including the terminating null character.
 *
 * @param len input size
 * @returns output size
 *
 * @ingroup base64
 */
size_t base64_encoded_size(size_t len)
{
	return(((len + 2) / 3) * 4);
}

/** Compute size of needed storage for decoding. This function computes the
 *  \e estimated size of a memory area needed to hold the result of a decoding
 *  operation, not including the terminating null character. Note that this
 *  function may return up to two bytes more due to the nature of Base64.
 *
 * @param len input size
 * @returns output size
 *
 * @ingroup base64
 */
size_t base64_decoded_size(size_t len)
{
	return((len / 4) * 3);
}

/** Encode an arbitrary size memory area. This function encodes the first
 *  \c len bytes of the contents of the memory area pointed to by \c in and
 *  stores the result in the memory area pointed to by \c out. The result will
 *  be null-terminated.
 *
 * @attention This function can't check if there's enough space at the memory
 *            memory location pointed to by \c out, so be careful.
 *
 * @param out pointer to destination
 * @param in pointer to source
 * @param len input size in bytes
 * @returns nothing
 *
 * @ingroup base64
 */
void base64_encode_binary(char *out, const unsigned char *in, size_t len)
{
	int size;
	size_t i = 0;
	
	while(i < len) {
		size = (len-i < 4) ? len-i : 4;
		
		base64_encode_block((unsigned char *)out, in, size);
		
		out += 4;
		in  += 3;
		i   += 3;
	}
	
	*out = '\0';
}

/** Decode an arbitrary size memory area. This function decodes the
 *  base64-string pointed to by \c in and stores the result in the memory area
 *  pointed to by \c out. The result will \e not be null-terminated.
 *
 * @attention This function can't check if there's enough space at the memory
 *            memory location pointed to by \c out, so be careful.
 *
 * @param out pointer to destination
 * @param in pointer to source
 * @returns -1 on error (illegal character) or the number of bytes decoded
 *
 * @ingroup base64
 */
int base64_decode_binary(unsigned char *out, const char *in)
{
	size_t len = strlen(in), i = 0;
	int numbytes = 0;
	
	while(i < len) {
		if((numbytes += base64_decode_block(out, (unsigned char *)in)) < 0)
			return(-1);
		
		out += 3;
		in  += 4;
		i   += 4;
	}
	
	return(numbytes);
}

/** Encode a string. This is a convenience function. It encodes the first
 *  \c size bytes of the string pointed to by \c in, stores the null-terminated
 *  result in a newly created memory area and returns a pointer to it.
 *
 * @attention After a call to base64_encode(), you have to free() the result
 *  yourself.
 *
 * @param in pointer to string
 * @param size strlen
 * @returns NULL on error (not enough memory) or a pointer to the encoded result
 *
 * @ingroup base64
 */
char *base64_encode(const char *in, size_t size)
{
	char *out;
	size_t outlen;
	
	if(in == NULL)
		return(NULL);
	
	if(size == 0)
		size = strlen(in);
	
	outlen = base64_encoded_size(size);
	
	if((out = (char *)malloc(sizeof(char) * (outlen + 1))) == NULL)
		return(NULL);
	
	base64_encode_binary(out, (unsigned char *)in, size);
	
	return(out);
}

/** Decode a string. This is a convenience function. It decodes the
 *  null-terminated string pointed to by \c in, stores the result in a newly
 *  created memory area and returns a pointer to it. The result will be
 *  null-terminated.
 *
 * @attention After a call to base64_decode(), you have to free() the result
 *  yourself.
 *
 * @param in pointer to string
 * @returns NULL on error (not enough memory) or a pointer to the decoded result
 *
 * @ingroup base64
 */
char *base64_decode(const char *in)
{
	char *out;
	size_t outlen;
	int numbytes;
	
	outlen = base64_decoded_size(strlen(in));
	
	if((out = (char *)malloc(sizeof(char) * (outlen + 1))) == NULL)
		return(NULL);
	
	if((numbytes = base64_decode_binary((unsigned char *)out, in)) < 0) {
		free(out);
		return(NULL);
	}
	
	*(out + numbytes) = '\0';
	
	return(out);
}
