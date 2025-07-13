import React from 'react'
import cn from '@/utils/classnames'

type LogoProps = {
  size?: 'small' | 'medium' | 'large'
  className?: string
}

const CustomLogo: React.FC<LogoProps> = ({ size = 'small', className }) => {
  const sizeMap = {
    small: 'h-5 w-auto',
    medium: 'h-8 w-auto', 
    large: 'h-10 w-auto',
  }

  return (
    <img 
      src="/custom/logo.jpeg" 
      alt="金融信贷" 
      className={cn('block', sizeMap[size], className)}
    />
  )
}

export default CustomLogo