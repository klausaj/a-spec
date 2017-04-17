/*******************************************************************************
 *  Copyright (c) 2009, A-Spec Project                                         *
 *  All rights reserved.                                                       *
 *                                                                             *
 *  Redistribution and use in source and binary forms, with or without         *
 *  modification, are permitted provided that the following conditions         *
 *  are met:                                                                   *
 *      - Redistributions of source code must retain the above copyright       *
 *        notice, this list of conditions and the following disclaimer.        *
 *      - Redistributions in binary form must reproduce the above copyright    *
 *        notice, this list of conditions and the following disclaimer in the  *
 *        documentation and/or other materials provided with the distribution. *
 *      - Neither the name of the A-Spec Project nor the names of its          *
 *        contributors may be used to endorse or promote products derived from *
 *        this software without specific prior written permission.             *
 *                                                                             *
 *  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS        *
 *  "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED  *
 *  TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR *
 *  PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR          *
 *  CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,      *
 *  EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,        *
 *  PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR         *
 *  PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF     *
 *  LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING       *
 *  NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS         *
 *  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.               *
 *******************************************************************************/

#include <string.h>
#include <stdarg.h>
#include <stdlib.h>
#include <stdio.h>

#include "arch/mingw/a-spec_mingw.h"
#include "a-specc/a-specc_types.h"

int asprintf(char **strp, const char *fmt, ...)
{
   va_list  ap;

   if((strp == NULL) || (fmt == NULL))
   {
      return -1;
   }

   va_start(ap, fmt);

   return vasprintf(strp, fmt, ap);
}

int vasprintf(char **strp, const char *fmt, va_list ap)
{
   UINT32  reqSize = vsnprintf(NULL, 0, fmt, ap);

   if((strp == NULL) || (fmt == NULL))
   {
      return -1;
   }

   if(reqSize > 0)
   {
      *strp = malloc(reqSize + 1);

      vsprintf(*strp, fmt, ap);
   }

   return reqSize;
}

char *strndup(const char *s, size_t n)
{
   UINT32  sLen    = -1;
   INT8    *retStr = NULL;

   if(s == NULL)
   {
      return NULL;
   }

   sLen = strlen(s);

   if(n < sLen)
   {
      sLen = n;
   }

   retStr = malloc(sLen + 1);

   memset(retStr, 0, sLen + 1);
   strncpy(retStr, s, sLen);

   return retStr;
}

char *index(const char *s, int c)
{
   UINT32  sLen = -1;
   UINT32  sIdx = 0;

   if(s == NULL)
   {
      return NULL;
   }

   sLen = strlen(s);

   for(sIdx = 0; sIdx < sLen; sIdx++)
   {
      if(s[sIdx] == c)
      {
         return (char *) &(s[sIdx]);
      }
   }

   return NULL;
}

char *rindex(const char *s, int c)
{
   UINT32  sLen = -1;
   INT32   sIdx = 0;

   if(s == NULL)
   {
      return NULL;
   }

   sLen = strlen(s);

   for(sIdx = sLen - 1; sIdx >= 0; sIdx--)
   {
      if(s[sIdx] == c)
      {
         return (char *) &(s[sIdx]);
      }
   }

   return NULL;
}
